<?php

namespace Database\Seeders;

use App\Models\ProfilAdmin;
use App\Models\ProfilEtudiant;
use App\Models\ProfilLyceen;
use App\Models\Universite;
use App\Models\Utilisateur;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Comptes de démonstration pour la soutenance — un compte par rôle, même mot de passe.
 * Ce mot de passe n'est jamais dans le code (dépôt GitHub public) : il est lu dans
 * backend/.env (DEMO_MOT_DE_PASSE) ; sans valeur, un mot de passe aléatoire est utilisé.
 * ATTENTION : à ne jamais exécuter tel quel en production (voir README).
 */
class UtilisateurSeeder extends Seeder
{
    public function run(): void
    {
        $motDePasseDemo = Hash::make(env('DEMO_MOT_DE_PASSE') ?: Str::random(32));

        $lyceen = Utilisateur::create([
            'nom' => 'Diop', 'prenom' => 'Aminata', 'email' => 'lyceen@demo.sn',
            'mot_de_passe' => $motDePasseDemo, 'role' => 'lyceen', 'region' => 'Dakar', 'statut' => 'actif',
        ]);

        ProfilLyceen::create([
            'utilisateur_id' => $lyceen->id, 'serie_bac' => 'S2', 'moyenne_generale' => 14.5,
            'passions' => ['informatique', 'entrepreneuriat'], 'matieres_fortes' => ['Mathématiques', 'Physique-Chimie'],
            'metiers_envisages' => ['développeur', 'data analyst'],
            'mobilite' => true, 'pref_public_prive' => 'indifferent',
            'region_cible' => 'Dakar', 'annee_terminale' => 2026,
        ]);

        $etudiant = Utilisateur::create([
            'nom' => 'Ndiaye', 'prenom' => 'Moussa', 'email' => 'etudiant@demo.sn',
            'mot_de_passe' => $motDePasseDemo, 'role' => 'etudiant', 'region' => 'Thiès', 'statut' => 'actif',
        ]);

        ProfilEtudiant::create([
            'utilisateur_id' => $etudiant->id, 'universite_actuelle' => 'UCAD', 'formation_actuelle' => 'Licence Informatique',
            'niveau_actuel' => 'L2', 'domaines_interets' => ['informatique', 'réseaux'],
            'recherche_stage' => true, 'recherche_emploi' => false,
        ]);

        $superAdmin = Utilisateur::create([
            'nom' => 'Sy', 'prenom' => 'Fatou', 'email' => 'superadmin@demo.sn',
            'mot_de_passe' => $motDePasseDemo, 'role' => 'super_admin', 'statut' => 'actif',
        ]);

        ProfilAdmin::create([
            'utilisateur_id' => $superAdmin->id, 'universite_id' => null, 'niveau_acces' => 'super_admin',
            'organisation' => 'Super App Étudiante Sénégalaise', 'date_prise_fonction' => now(),
        ]);

        $ucad = Universite::where('code_unique', 'UCAD')->first();

        if ($ucad) {
            $adminEtab = Utilisateur::create([
                'nom' => 'Fall', 'prenom' => 'Ibrahima', 'email' => 'admin.ucad@demo.sn',
                'mot_de_passe' => $motDePasseDemo, 'role' => 'admin_etablissement', 'statut' => 'actif',
            ]);

            ProfilAdmin::create([
                'utilisateur_id' => $adminEtab->id, 'universite_id' => $ucad->id, 'niveau_acces' => 'admin_etablissement',
                'organisation' => 'UCAD', 'date_prise_fonction' => now(),
            ]);
        }
    }
}
