<?php

namespace App\Providers;

use Illuminate\Support\Facades\URL;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Les Policies (App\Policies\{Model}Policy) sont auto-découvertes par Laravel
        // grâce à la convention de nommage — aucun enregistrement manuel nécessaire.
    }

    public function boot(): void
    {
        // Force les URLs de réinitialisation de mot de passe en HTTPS en production
        // (CDC §3.3 "HTTPS obligatoire sur l'ensemble de la plateforme").
        if ($this->app->environment('production')) {
            URL::forceScheme('https');
        }
    }
}
