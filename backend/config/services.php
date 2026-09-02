<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Service Django IA (interne, jamais exposé à Flutter — CDC §9)
    |--------------------------------------------------------------------------
    */
    'django_ia' => [
        'base_url' => env('DJANGO_IA_BASE_URL', 'http://django-ia:8000'),
        'internal_key' => env('DJANGO_IA_INTERNAL_KEY'),
        'timeout' => env('DJANGO_IA_TIMEOUT', 30),
    ],

    /*
    |--------------------------------------------------------------------------
    | Frontend Flutter (pour les deep-links, ex. réinitialisation mot de passe)
    |--------------------------------------------------------------------------
    */
    'frontend' => [
        'reset_password_url' => env('FRONTEND_RESET_PASSWORD_URL', 'https://app.superapp.sn/reset-password'),
    ],

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'resend' => [
        'key' => env('RESEND_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

];
