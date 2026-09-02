<?php

namespace Database\Seeders;

use App\Models\ProfilAdmin;
use App\Models\Utilisateur;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

/**
 * Comptes super-administrateur de l'équipe projet Ndimbeul-Etudiant.
 * Idempotent (firstOrCreate) — peut être re-exécuté sans erreur de
 * contrainte unique sur l'email.
 *
 * ATTENTION : mots de passe par défaut, à changer par chaque membre depuis
 * son profil une fois les comptes testés — ne jamais les garder tels quels
 * en production ou en soutenance publique.
 */
class AdminUsersSeeder extends Seeder
{
    public function run(): void
    {
        $membres = [
            ['nom' => 'Niang', 'prenom' => 'Paya', 'email' => 'paya@ndimbeul-etudiant.sn', 'mot_de_passe' => '***MOT-DE-PASSE-RETIRE***'],
            ['nom' => 'Gadiaga', 'prenom' => 'Khady', 'email' => 'khady@ndimbeul-etudiant.sn', 'mot_de_passe' => '***MOT-DE-PASSE-RETIRE***'],
            ['nom' => 'Cissokho', 'prenom' => 'Coumba', 'email' => 'coumba@ndimbeul-etudiant.sn', 'mot_de_passe' => '***MOT-DE-PASSE-RETIRE***'],
            ['nom' => 'Sarr', 'prenom' => 'Fatou', 'email' => 'fatou@ndimbeul-etudiant.sn', 'mot_de_passe' => '***MOT-DE-PASSE-RETIRE***'],
        ];

        foreach ($membres as $membre) {
            $utilisateur = Utilisateur::firstOrCreate(
                ['email' => $membre['email']],
                [
                    'nom' => $membre['nom'],
                    'prenom' => $membre['prenom'],
                    'mot_de_passe' => Hash::make($membre['mot_de_passe']),
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
