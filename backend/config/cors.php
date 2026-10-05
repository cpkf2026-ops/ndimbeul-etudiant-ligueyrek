<?php

return [

    // Toutes les routes /api/* doivent accepter les requêtes de l'app Flutter Web
    // (CDC §3.4 "Compatibilité web : Chrome, Firefox, Safari, Edge").
    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => explode(',', (string) env('CORS_ALLOWED_ORIGINS', 'http://localhost:5000')),

    // En développement local uniquement : `flutter run -d chrome` choisit un port
    // différent à chaque lancement — on accepte donc localhost/127.0.0.1 sur tout port.
    'allowed_origins_patterns' => env('APP_ENV') === 'local'
        ? ['#^http://(localhost|127\.0\.0\.1)(:\d+)?$#']
        : [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
