<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\UploadDocumentRequest;
use App\Services\AuditLogger;
use App\Services\DjangoAiClient;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

/**
 * POST /api/v1/admin/documents/upload — import PDF vers l'index FAISS de Django (UC12).
 * Laravel stocke temporairement le fichier puis relaie le contenu à Django pour
 * chunking + embeddings + indexation (§9 CDC : Laravel jamais ne fait de RAG lui-même).
 */
class DocumentController extends Controller
{
    public function __construct(
        private readonly DjangoAiClient $django,
        private readonly AuditLogger $auditLogger,
    ) {}

    public function upload(UploadDocumentRequest $request): JsonResponse
    {
        $fichier = $request->file('document');
        $chemin = $fichier->store('documents-a-indexer', 'local');
        $cheminAbsolu = Storage::disk('local')->path($chemin);

        $reponse = $this->django->indexDocument(
            $cheminAbsolu,
            $fichier->getClientOriginalName(),
            [
                'source_id' => $request->input('source_id'),
                'universite_id' => $request->input('universite_id'),
                'categorie' => $request->input('categorie'),
            ]
        );

        // Le fichier temporaire n'a plus lieu d'être une fois son CONTENU transmis à Django
        // (voir DjangoAiClient::indexDocument — envoi multipart, pas juste le chemin).
        Storage::disk('local')->delete($chemin);

        if ($reponse->failed()) {
            return response()->json(['message' => 'Échec de l\'indexation côté service IA.'], 502);
        }

        $this->auditLogger->log($request->user(), 'create', 'documents_rag', null, null, [
            'nom_fichier' => $fichier->getClientOriginalName(),
        ]);

        return response()->json([
            'message' => 'Document envoyé pour indexation.',
            'data' => $reponse->json(),
        ], 202);
    }
}
