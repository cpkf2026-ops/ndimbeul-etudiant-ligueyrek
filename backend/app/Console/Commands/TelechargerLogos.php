<?php

namespace App\Console\Commands;

use App\Models\Universite;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * Tâche 2 du cahier des charges "développeur senior" : les logos ne sont pas
 * chargés en direct depuis le site externe (lien cassé si le site change/tombe,
 * lenteur, CORS) — on les télécharge une fois dans storage/app/public/logos/ et
 * `image_url` pointe ensuite vers ce fichier local servi par Laravel.
 *
 * N'invente rien : si le téléchargement échoue ou que le contenu n'est pas une
 * image exploitable, l'établissement reste sans logo (image_url inchangée) —
 * l'app affiche alors l'avatar généré (nom sur fond de couleur) côté Flutter.
 */
class TelechargerLogos extends Command
{
    protected $signature = 'etablissements:telecharger-logos';
    protected $description = 'Télécharge et stocke localement les logos dont image_url pointe encore vers un site externe';

    public function handle(): int
    {
        $aTelecharger = Universite::where('statut_actif', true)
            ->whereNotNull('image_url')
            ->where('image_url', 'not like', '/storage/logos/%')
            ->get();

        $telecharges = 0;
        $echecs = 0;

        foreach ($aTelecharger as $universite) {
            $urlDistante = $universite->image_url;

            try {
                $reponse = Http::withHeaders([
                    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                ])->timeout(10)->get($urlDistante);

                if (! $reponse->successful()) {
                    throw new \RuntimeException("HTTP {$reponse->status()}");
                }

                $contentType = $reponse->header('Content-Type', '');
                if (! str_starts_with($contentType, 'image/')) {
                    throw new \RuntimeException("Content-Type inattendu : {$contentType}");
                }

                $extension = match (true) {
                    str_contains($contentType, 'png') => 'png',
                    str_contains($contentType, 'svg') => 'svg',
                    str_contains($contentType, 'webp') => 'webp',
                    default => 'jpg',
                };

                $nomFichier = Str::slug($universite->code_unique).'.'.$extension;
                Storage::disk('public')->put('logos/'.$nomFichier, $reponse->body());

                $universite->image_url = '/storage/logos/'.$nomFichier;
                $universite->save();

                $telecharges++;
                $this->info("OK  {$universite->nom} -> logos/{$nomFichier}");
            } catch (\Throwable $e) {
                $echecs++;
                $this->warn("ÉCHEC {$universite->nom} ({$urlDistante}) : {$e->getMessage()}");
            }
        }

        $this->newLine();
        $this->info("Logos téléchargés : {$telecharges}/{$aTelecharger->count()} (échecs : {$echecs}).");

        return self::SUCCESS;
    }
}
