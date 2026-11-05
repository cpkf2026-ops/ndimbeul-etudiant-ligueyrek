<?php

use App\Console\Commands\EnvoyerAlertesEmploi;
use App\Console\Commands\PurgerOffresExpirees;
use App\Console\Commands\VerifierLiensOffres;
use App\Models\Utilisateur;
use Database\Seeders\AdminUsersSeeder;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schedule;
use Illuminate\Support\Str;

// Tâches planifiées (CDC §5.5, §8.1 "suppression automatique des annonces expirées",
// §8.3 "alertes personnalisées"). Exécutées via le scheduler Laravel (cron unique
// `* * * * * php artisan schedule:run`), séparément de Celery côté Django.
Schedule::command(PurgerOffresExpirees::class)->daily();
Schedule::command(EnvoyerAlertesEmploi::class)->hourly();
// Tâche 5 : vérifie que les liens sources des offres actives répondent toujours.
Schedule::command(VerifierLiensOffres::class)->daily();

// Applique aux comptes administrateurs et de démonstration les mots de passe définis dans
// backend/.env (ADMIN_MDP_*, DEMO_MOT_DE_PASSE). Les anciens mots de passe figuraient dans le
// code, donc dans l'historique GitHub : après cette commande, ils ne fonctionnent plus.
Artisan::command('comptes:securiser', function () {
    $comptes = collect(AdminUsersSeeder::MEMBRES)->map(fn ($m) => [$m['email'], $m['variable']])
        ->merge(collect(['lyceen@demo.sn', 'etudiant@demo.sn', 'superadmin@demo.sn', 'admin.ucad@demo.sn'])
            ->map(fn ($email) => [$email, 'DEMO_MOT_DE_PASSE']));

    foreach ($comptes as [$email, $variable]) {
        $utilisateur = Utilisateur::where('email', $email)->first();
        if (! $utilisateur) {
            continue;
        }
        $motDePasse = env($variable);
        if (! $motDePasse || strlen($motDePasse) < 10) {
            // Pas de mot de passe (ou trop court) dans .env : compte verrouillé par un mot de
            // passe aléatoire plutôt que laissé avec l'ancien, connu de tous.
            $utilisateur->update(['mot_de_passe' => Hash::make(Str::random(32))]);
            $this->warn("{$email} : {$variable} absent ou trop court (10 caractères minimum) — compte verrouillé.");
            continue;
        }
        $utilisateur->update(['mot_de_passe' => Hash::make($motDePasse)]);
        $utilisateur->tokens()->delete(); // déconnecte les sessions ouvertes avec l'ancien mot de passe
        $this->info("{$email} : nouveau mot de passe appliqué.");
    }
})->purpose('Applique les mots de passe de .env aux comptes administrateurs et de démonstration');
