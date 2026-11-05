<?php

namespace Database\Seeders;

use App\Models\ProfilAdmin;
use App\Models\Utilisateur;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Comptes super-administrateur de l'équipe projet Ndimbeul-Etudiant.
 * Idempotent (firstOrCreate) — peut être re-exécuté sans erreur de
 * contrainte unique sur l'email.
 *
 * Mots de passe : jamais dans le code (le dépôt GitHub peut être public). Ils sont lus
 * dans backend/.env (ADMIN_MDP_PAYA, ADMIN_MDP_KHADY, ADMIN_MDP_COUMBA, ADMIN_MDP_FATOU) ;
 * sans valeur, un mot de passe aléatoire est utilisé (compte inutilisable tant qu'il
 * n'est pas défini). Pour appliquer ces mots de passe à des comptes déjà créés :
 *     php artisan comptes:securiser
 */
class AdminUsersSeeder extends Seeder
{
    /** Membres de l'équipe : [nom, prénom, e-mail, variable .env du mot de passe]. */
    public const MEMBRES = [
        ['nom' => 'Niang', 'prenom' => 'Paya', 'email' => 'paya@ndimbeul-etudiant.sn', 'variable' => 'ADMIN_MDP_PAYA'],
        ['nom' => 'Gadiaga', 'prenom' => 'Khady', 'email' => 'khady@ndimbeul-etudiant.sn', 'variable' => 'ADMIN_MDP_KHADY'],
        ['nom' => 'Cissokho', 'prenom' => 'Coumba', 'email' => 'coumba@ndimbeul-etudiant.sn', 'variable' => 'ADMIN_MDP_COUMBA'],
        ['nom' => 'Sarr', 'prenom' => 'Fatou', 'email' => 'fatou@ndimbeul-etudiant.sn', 'variable' => 'ADMIN_MDP_FATOU'],
    ];

    public function run(): void
    {
        foreach (self::MEMBRES as $membre) {
            $motDePasse = env($membre['variable']) ?: Str::random(32);
            $utilisateur = Utilisateur::firstOrCreate(
                ['email' => $membre['email']],
                [
                    'nom' => $membre['nom'],
                    'prenom' => $membre['prenom'],
                    'mot_de_passe' => Hash::make($motDePasse),
                    'role' => Utilisateur::ROLE_SUPER_ADMIN,
                    'statut' => 'actif',
                ]
            );

            ProfilAdmin::firstOrCreate(
                ['utilisateur_id' => $utilisateur->id],
                [
                    'universite_id' => null,
                    'niveau_acces' => 'super_admin',
                    'organisation' => 'Ndimbeul-Etudiant — Équipe projet',
                    'date_prise_fonction' => now(),
                ]
            );
        }
    }
}
