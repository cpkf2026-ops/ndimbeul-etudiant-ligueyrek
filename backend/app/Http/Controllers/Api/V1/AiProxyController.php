<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\AiChatRequest;
use App\Models\ConversationIa;
use App\Services\DjangoAiClient;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Point central Laravel <-> Django (CDC §5.1, §9). Laravel valide le JWT/Sanctum,
 * enrichit la requête avec le profil de l'étudiant, puis relaie vers Django via
 * X-Internal-Key. Django n'est jamais exposé directement à Flutter.
 */
class AiProxyController extends Controller
{
    public function __construct(private readonly DjangoAiClient $django) {}

    /**
     * POST /api/v1/ai/chat — relai streaming SSE (diagramme de séquence UC04, CDC §9.1).
     */
    public function chat(AiChatRequest $request): StreamedResponse
    {
        $utilisateur = $request->user();
        $conversationId = $request->input('conversation_id');

        $conversation = $conversationId
            ? ConversationIa::where('id', $conversationId)->where('utilisateur_id', $utilisateur->id)->firstOrFail()
            : ConversationIa::create(['utilisateur_id' => $utilisateur->id, 'messages' => []]);

        $profil = $utilisateur->estLyceen()
            ? $utilisateur->profilLyceen?->versProfilPourIa()
            : ($utilisateur->profilEtudiant?->toArray() ?? []);

        $payload = [
            'utilisateur_id' => $utilisateur->id,
            'message' => $request->input('message'),
            'profil' => $profil ?? [],
            'conversation_id' => $conversation->id,
        ];

        return response()->stream(function () use ($payload, $conversation) {
            $body = $this->django->chatStream($payload);
            $reponseComplete = '';

            while (! $body->eof()) {
                $chunk = $body->read(1024);
                $reponseComplete .= $chunk;
                echo $chunk;

                if (ob_get_level() > 0) {
                    ob_flush();
                }
                flush();
            }

            // Persistance de la conversation côté Laravel une fois le stream terminé
            // (Django persiste aussi côté conversations_ia — double écriture tolérée,
            // la dernière écriture fait foi, cf. schéma "flux utilisateur IA").
            $conversation->ajouterMessage('user', $payload['message']);
            $conversation->ajouterMessage('assistant', $reponseComplete);
        }, 200, [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'X-Accel-Buffering' => 'no',
            'Connection' => 'keep-alive',
        ]);
    }

    /**
     * GET /api/v1/ai/recommendations — relai vers le moteur de scoring Django (CDC §5.2).
     */
    public function recommendations(Request $request): JsonResponse
    {
        $utilisateur = $request->user();

        if (! $utilisateur->estLyceen() || ! $utilisateur->profilLyceen) {
            return response()->json([
                'message' => 'Les recommandations nécessitent un profil lycéen complété.',
            ], 422);
        }

        if (! $utilisateur->profilLyceen->estComplet()) {
            return response()->json([
                'message' => 'Profil incomplet : complétez-le pour obtenir des suggestions pertinentes.',
                'completude' => $utilisateur->profilLyceen->calculerCompletude(),
            ], 422);
        }

        $reponse = $this->django->recommendations([
            'utilisateur_id' => $utilisateur->id,
            'profil' => $utilisateur->profilLyceen->versProfilPourIa(),
        ]);

        if ($reponse->failed()) {
            return response()->json(['message' => 'Le service de recommandation est momentanément indisponible.'], 502);
        }

        return response()->json($reponse->json());
    }

    /**
     * GET /api/v1/ai/conversations — historique des conversations de l'étudiant
     * (CDC / Analyse des besoins §2.5 "Historique des conversations sauvegardé et
     * accessible depuis l'espace étudiant" — manquait entièrement à la première livraison,
     * seul l'endpoint d'envoi de message existait).
     */
    public function conversations(Request $request): JsonResponse
    {
        $conversations = ConversationIa::where('utilisateur_id', $request->user()->id)
            ->orderByDesc('date_derniere_activite')
            ->get(['id', 'date_derniere_activite', 'created_at']);

        return response()->json(['data' => $conversations]);
    }

    /**
     * GET /api/v1/ai/conversations/{id} — relecture complète d'une conversation.
     */
    public function conversation(Request $request, string $id): JsonResponse
    {
        $conversation = ConversationIa::where('id', $id)
            ->where('utilisateur_id', $request->user()->id)
            ->firstOrFail();

        return response()->json(['data' => $conversation]);
    }
}
