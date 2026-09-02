<?php

use Illuminate\Support\Facades\Route;

// Backend 100% API — pas d'interface web Blade. Cette route sert uniquement
// de vérification rapide que le serveur répond.
Route::get('/', function () {
    return response()->json([
        'application' => 'Super App Étudiante Sénégalaise — API Laravel',
        'documentation' => '/api/docs',
    ]);
});
