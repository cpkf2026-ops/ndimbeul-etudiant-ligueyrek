<?php

namespace Database\Seeders;

use App\Models\Universite;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\File;

/**
 * Catalogue des établissements d'enseignement supérieur et de formation
 * professionnelle du Sénégal — lit `database/seeders/data/etablissements.json`.
 *
 * Remplace UniversiteSeeder (Tâche 1 du cahier des charges "développeur senior") :
 * contrairement à l'ancien seeder, AUCUNE donnée n'est ici devinée ou générée par
 * motif (ex: pas de "www.<sigle>.sn" suggéré à l'aveugle) — chaque site_web vient
 * d'une recherche web réelle puis d'une vérification HTTP effective (voir le champ
 * `source` de chaque entrée), et tout ce qui n'a pas pu être vérifié reste `null`
 * plutôt que d'être inventé.
 *
 * Idempotent : updateOrCreate sur `code_unique` (le "sigle"), donc rejouable sans
 * créer de doublons — une ré-exécution met simplement à jour les fiches existantes.
 */
class EtablissementsSeeder extends Seeder
{
    public function run(): void
    {
        $chemin = database_path('seeders/data/etablissements.json');

        if (! File::exists($chemin)) {
            $this->command?->error("Fichier introuvable : {$chemin}");
            return;
        }

        $etablissements = json_decode(File::get($chemin), true, flags: JSON_THROW_ON_ERROR);

        $crees = 0;
        $mis_a_jour = 0;

        foreach ($etablissements as $data) {
            $universite = Universite::where('code_unique', $data['sigle'])->first();

            Universite::updateOrCreate(
                ['code_unique' => $data['sigle']],
                [
                    'nom' => $data['nom'],
                    'region' => $data['region'],
                    'commune' => $data['ville'],
                    'type' => $data['type'] === 'formation_pro' ? 'public' : $data['type'],
                    'site_web_officiel' => $data['site_web'],
                    'source' => $data['source'],
                    'date_verification' => $data['date_verification'],
                    'image_url' => $data['logo_url'],
                    'email_contact' => $data['email'],
                    'telephone_contact' => $data['telephone'],
                    'statut_actif' => true,
                ]
            );

            $universite ? $mis_a_jour++ : $crees++;
        }

        $this->command?->info(
            "Établissements : {$crees} créé(s), {$mis_a_jour} mis à jour, ".count($etablissements).' au total dans le fichier.'
        );
    }
}
