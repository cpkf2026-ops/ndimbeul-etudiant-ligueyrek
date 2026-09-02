<?php

return [

    'defaults' => [
        'guard' => 'web',
        'passwords' => 'utilisateurs',
    ],

    /*
    |--------------------------------------------------------------------------
    | Guards
    |--------------------------------------------------------------------------
    | 'sanctum' est le guard utilisé par toutes les routes API (voir routes/api.php,
    | middleware auth:sanctum). 'web' reste pour compatibilité (aucune route Blade ici).
    */
    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'utilisateurs',
        ],

        'sanctum' => [
            'driver' => 'sanctum',
            'provider' => 'utilisateurs',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Providers
    |--------------------------------------------------------------------------
    | Le CDC utilise "utilisateurs" comme nom de table/modèle plutôt que le
    | conventionnel "users" — le provider est renommé en conséquence.
    */
    'providers' => [
        'utilisateurs' => [
            'driver' => 'eloquent',
            'model' => App\Models\Utilisateur::class,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Réinitialisation de mot de passe (CDC §2.1, §3.3)
    |--------------------------------------------------------------------------
    */
    'passwords' => [
        'utilisateurs' => [
            'provider' => 'utilisateurs',
            'table' => 'password_reset_tokens',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],

    'password_timeout' => 10800,

];
