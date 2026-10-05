<?php

use App\Http\Controllers\Api\V1\Admin\DocumentController;
use App\Http\Controllers\Api\V1\Admin\FicheAdminController;
use App\Http\Controllers\Api\V1\Admin\FormationAdminController;
use App\Http\Controllers\Api\V1\Admin\QualityController;
use App\Http\Controllers\Api\V1\Admin\SourceController;
use App\Http\Controllers\Api\V1\Admin\UniversityAdminController;
use App\Http\Controllers\Api\V1\Admin\UserAdminController;
use App\Http\Controllers\Api\V1\AiProxyController;
use App\Http\Controllers\Api\V1\AlertController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\FormationController;
use App\Http\Controllers\Api\V1\JobController;
use App\Http\Controllers\Api\V1\MediaController;
use App\Http\Controllers\Api\V1\NewsController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\UniversityController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — Super App Étudiante Sénégalaise
|--------------------------------------------------------------------------
| Préfixe /api/v1/ (voir bootstrap/app.php pour le montage), Auth Bearer Sanctum.
| Documentation Swagger générée via L5-Swagger : /api/docs
|
| RÈGLE D'ORDRE IMPORTANTE : Laravel matche les routes dans leur ORDRE
| D'ENREGISTREMENT, indépendamment des groupes/middlewares qui les entourent.
| Toute route statique (ex. /formations/favorites) DOIT être déclarée AVANT
| la route générique correspondante (/formations/{formation}), sinon le
| segment statique est capturé par erreur comme paramètre {id} et provoque
| un 404 (bug identifié et corrigé lors de la revue finale).
*/

Route::prefix('v1')->group(function () {

    // --- Authentification (publique) ---
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
        Route::post('/reset-password', [AuthController::class, 'resetPassword']);

        Route::middleware('auth:sanctum')->group(function () {
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::post('/refresh', [AuthController::class, 'refresh']);
        });
    });

    // --- Profil (authentifié, tous rôles) ---
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/profile/me', [ProfileController::class, 'show']);
        Route::put('/profile/me', [ProfileController::class, 'update']);
        // Hors garde-fou 'profil.complete' : c'est la route qui le satisfait.
        Route::post('/profile/complete', [ProfileController::class, 'complete']);
    });

    // --- Universités : routes statiques d'abord, {universite} en dernier ---
    Route::get('/universities', [UniversityController::class, 'index']);
    Route::get('/universities/compare', [UniversityController::class, 'compare']);
    Route::middleware(['auth:sanctum', 'profil.complete'])->group(function () {
        Route::get('/universities/history', [UniversityController::class, 'history']);
    });
    Route::get('/universities/{universite}', [UniversityController::class, 'show']);
    Route::middleware(['auth:sanctum', 'profil.complete'])->group(function () {
        Route::post('/universities/{universite}/track', [UniversityController::class, 'track']);
    });

    // --- Formations : routes statiques d'abord, {formation} en dernier ---
    Route::get('/formations', [FormationController::class, 'index']);
    Route::get('/formations/compare', [FormationController::class, 'compare']);
    Route::middleware(['auth:sanctum', 'profil.complete'])->group(function () {
        Route::get('/formations/favorites', [FormationController::class, 'favorites']);
    });
    Route::get('/formations/{formation}', [FormationController::class, 'show']);
    Route::middleware(['auth:sanctum', 'profil.complete'])->group(function () {
        Route::post('/formations/{formation}/favorite', [FormationController::class, 'favorite']);
        Route::delete('/formations/{formation}/favorite', [FormationController::class, 'unfavorite']);
    });

    // --- Offres emploi/stage : routes statiques d'abord, {job} en dernier ---
    Route::get('/jobs', [JobController::class, 'index']);
    Route::middleware(['auth:sanctum', 'profil.complete'])->group(function () {
        Route::get('/jobs/favorites', [JobController::class, 'favorites']);
    });
    Route::get('/jobs/{job}', [JobController::class, 'show']);
    Route::middleware(['auth:sanctum', 'profil.complete'])->group(function () {
        Route::post('/jobs/{job}/favorite', [JobController::class, 'favorite']);
        Route::delete('/jobs/{job}/favorite', [JobController::class, 'unfavorite']);
    });

    // --- Médias (publique) : logos/images téléchargés localement par la veille IA,
    // servis avec CORS explicite (voir MediaController) ---
    Route::get('/media/{path}', [MediaController::class, 'show'])->where('path', '.*');

    // --- Actualités (publique) ---
    Route::get('/news', [NewsController::class, 'index']);
    Route::get('/news/{actualite}', [NewsController::class, 'show']);

    // --- Alertes personnalisées, notifications, IA (authentifié) ---
    Route::middleware(['auth:sanctum', 'profil.complete'])->group(function () {
        Route::apiResource('alerts', AlertController::class)
            ->parameters(['alerts' => 'alerte'])
            ->only(['index', 'store', 'update', 'destroy']);

        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
        Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);

        Route::post('/ai/chat', [AiProxyController::class, 'chat']);
        Route::get('/ai/recommendations', [AiProxyController::class, 'recommendations']);
        Route::get('/ai/conversations', [AiProxyController::class, 'conversations']);
        Route::get('/ai/conversations/{id}', [AiProxyController::class, 'conversation']);
    });

    // --- Back-office établissement (admin_etablissement + super_admin) ---
    Route::middleware(['auth:sanctum', 'role:admin_etablissement,super_admin'])
        ->prefix('admin')
        ->group(function () {
            Route::apiResource('universities', UniversityAdminController::class)
                ->parameters(['universities' => 'universite'])
                ->only(['index', 'store', 'update', 'destroy']);

            Route::post('/universities/{universite}/formations', [FormationAdminController::class, 'store']);
            Route::put('/formations/{formation}', [FormationAdminController::class, 'update']);
            Route::delete('/formations/{formation}', [FormationAdminController::class, 'destroy']);

            Route::post('/universities/{universite}/bourses', [FicheAdminController::class, 'storeBourse']);
            Route::put('/bourses/{bourse}', [FicheAdminController::class, 'updateBourse']);
            Route::delete('/bourses/{bourse}', [FicheAdminController::class, 'destroyBourse']);

            Route::post('/universities/{universite}/logements', [FicheAdminController::class, 'storeLogement']);
            Route::put('/logements/{logement}', [FicheAdminController::class, 'updateLogement']);
            Route::delete('/logements/{logement}', [FicheAdminController::class, 'destroyLogement']);

            Route::post('/universities/{universite}/frais', [FicheAdminController::class, 'storeFrais']);
            Route::put('/frais/{fraisScolarite}', [FicheAdminController::class, 'updateFrais']);
            Route::delete('/frais/{fraisScolarite}', [FicheAdminController::class, 'destroyFrais']);

            Route::apiResource('sources', SourceController::class)->only(['index', 'store', 'update', 'destroy']);
            Route::post('/documents/upload', [DocumentController::class, 'upload']);
        });

    // --- Back-office plateforme (super_admin uniquement) ---
    Route::middleware(['auth:sanctum', 'role:super_admin'])
        ->prefix('admin')
        ->group(function () {
            Route::get('/users', [UserAdminController::class, 'index']);
            Route::put('/users/{utilisateur}/role', [UserAdminController::class, 'updateRole']);
            Route::put('/users/{utilisateur}/suspend', [UserAdminController::class, 'suspend']);
            Route::put('/users/{utilisateur}/reactivate', [UserAdminController::class, 'reactivate']);
            Route::delete('/users/{utilisateur}', [UserAdminController::class, 'destroy']);
            Route::get('/quality', [QualityController::class, 'index']);
        });
});
