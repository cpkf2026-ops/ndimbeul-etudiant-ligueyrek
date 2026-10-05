<?php

use App\Console\Commands\EnvoyerAlertesEmploi;
use App\Console\Commands\PurgerOffresExpirees;
use App\Console\Commands\VerifierLiensOffres;
use Illuminate\Support\Facades\Schedule;

// Tâches planifiées (CDC §5.5, §8.1 "suppression automatique des annonces expirées",
// §8.3 "alertes personnalisées"). Exécutées via le scheduler Laravel (cron unique
// `* * * * * php artisan schedule:run`), séparément de Celery côté Django.
Schedule::command(PurgerOffresExpirees::class)->daily();
Schedule::command(EnvoyerAlertesEmploi::class)->hourly();
// Tâche 5 : vérifie que les liens sources des offres actives répondent toujours.
Schedule::command(VerifierLiensOffres::class)->daily();
