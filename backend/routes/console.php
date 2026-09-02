<?php

use App\Console\Commands\EnvoyerAlertesEmploi;
use App\Console\Commands\PurgerOffresExpirees;
use Illuminate\Support\Facades\Schedule;

// Tâches planifiées (CDC §5.5, §8.1 "suppression automatique des annonces expirées",
// §8.3 "alertes personnalisées"). Exécutées via le scheduler Laravel (cron unique
// `* * * * * php artisan schedule:run`), séparément de Celery côté Django.
Schedule::command(PurgerOffresExpirees::class)->daily();
Schedule::command(EnvoyerAlertesEmploi::class)->hourly();
