<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Http\Resources\UtilisateurResource;
use App\Models\Utilisateur;
use App\Services\AuditLogger;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;

/**
 * Authentification via Laravel Sanctum (tokens opaques révocables — voir note README
 * sur la terminologie "Sanctum JWT" utilisée dans le CDC).
 */
class AuthController extends Controller
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $request->validated();

        $utilisateur = Utilisateur::create([
            'nom' => $data['nom'],
            'prenom' => $data['prenom'],
            'email' => $data['email'],
            'mot_de_passe' => Hash::make($data['mot_de_passe']),
            'region' => $data['region'] ?? null,
            'statut' => 'actif',
            'profil_complete' => false,
        ]);

        // `role` reste null et aucun profil spécialisé n'est créé ici : l'utilisateur
        // choisit son statut (lycéen/étudiant/diplômé) via POST /profile/complete,
        // route requise avant tout accès aux fonctionnalités métier (EnsureProfileComplete).
        $token = $utilisateur->createToken($request->input('device_name', 'default'))->plainTextToken;

        $this->auditLogger->connexion($utilisateur);

        return response()->json([
            'message' => 'Inscription réussie.',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'utilisateur' => new UtilisateurResource($utilisateur),
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $utilisateur = Utilisateur::where('email', $request->input('email'))->first();

        if (! $utilisateur || ! Hash::check($request->input('mot_de_passe'), $utilisateur->mot_de_passe)) {
            return response()->json(['message' => 'Identifiants incorrects.'], 401);
        }

        if (! $utilisateur->estActif()) {
            return response()->json(['message' => 'Ce compte est suspendu.'], 403);
        }

        $utilisateur->forceFill(['date_derniere_connexion' => now()])->save();

        $token = $utilisateur->createToken($request->input('device_name', 'default'))->plainTextToken;

        $this->auditLogger->connexion($utilisateur);

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'utilisateur' => new UtilisateurResource($utilisateur->load($this->profilRelation($utilisateur))),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $utilisateur = $request->user();
        $request->user()->currentAccessToken()->delete();

        $this->auditLogger->deconnexion($utilisateur);

        return response()->json(['message' => 'Déconnexion réussie.']);
    }

    /**
     * "Rafraîchissement" adapté à Sanctum : révoque le token courant et en émet un nouveau.
     * (Sanctum n'a pas de refresh token séparé comme un vrai JWT — voir README.)
     */
    public function refresh(Request $request): JsonResponse
    {
        $utilisateur = $request->user();
        $deviceName = $request->user()->currentAccessToken()->name ?? 'default';

        $request->user()->currentAccessToken()->delete();
        $token = $utilisateur->createToken($deviceName)->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $utilisateur = $request->user()->load($this->profilRelation($request->user()));

        return response()->json(['utilisateur' => new UtilisateurResource($utilisateur)]);
    }

    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $status = Password::broker('utilisateurs')->sendResetLink(
            $request->only('email')
        );

        // Toujours répondre 200 (même si l'email n'existe pas) pour ne pas divulguer
        // l'existence d'un compte — bonne pratique de sécurité.
        return response()->json([
            'message' => 'Si cet email existe, un lien de réinitialisation a été envoyé.',
        ]);
    }

    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        // IMPORTANT : Illuminate\Auth\Passwords\PasswordBroker attend en interne une clé
        // littérale "password" dans le tableau de credentials (EloquentUserProvider exclut
        // uniquement cette clé exacte avant de construire la requête WHERE de recherche de
        // l'utilisateur). Comme notre champ métier s'appelle "mot_de_passe" (CDC, nommage
        // français), on le remappe ici vers "password" pour ce seul appel — sinon Laravel
        // utilise "mot_de_passe" comme critère de recherche SQL (WHERE mot_de_passe = '...'
        // en clair) et ne trouve jamais l'utilisateur : la réinitialisation échoue silencieusement.
        $status = Password::broker('utilisateurs')->reset(
            [
                'email' => $request->input('email'),
                'token' => $request->input('token'),
                'password' => $request->input('mot_de_passe'),
                'password_confirmation' => $request->input('mot_de_passe_confirmation'),
            ],
            function (Utilisateur $utilisateur, string $motDePasse) {
                $utilisateur->forceFill([
                    'mot_de_passe' => Hash::make($motDePasse),
                    'remember_token' => Str::random(60),
                ])->save();

                $utilisateur->tokens()->delete(); // révoque toutes les sessions existantes

                event(new PasswordReset($utilisateur));
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            return response()->json(['message' => __($status)], 422);
        }

        return response()->json(['message' => 'Mot de passe réinitialisé avec succès.']);
    }

    private function profilRelation(Utilisateur $utilisateur): string
    {
        return match ($utilisateur->role) {
            'lyceen' => 'profilLyceen',
            'etudiant' => 'profilEtudiant',
            'diplome' => 'profilDiplome',
            'admin_etablissement', 'super_admin' => 'profilAdmin',
            // role encore null : profil pas complété, aucune relation à charger.
            default => 'profilLyceen',
        };
    }
}
