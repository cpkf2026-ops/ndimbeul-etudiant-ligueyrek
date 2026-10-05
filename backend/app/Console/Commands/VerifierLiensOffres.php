<?php

namespace App\Console\Commands;

use App\Models\OffreEmploi;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

/**
 * Tâche 5 du cahier des charges : vérifie périodiquement que le lien source de
 * chaque offre active répond toujours (HTTP 200), et désactive celles dont le
 * lien est mort — une offre dont la source a disparu n'est plus fiable.
 */
class VerifierLiensOffres extends Command
{
    protected $signature = 'offres:verifier-liens {--limite=100 : Nombre maximum d\'offres à vérifier par exécution}';
    protected $description = "Vérifie que le lien source des offres actives répond toujours (HTTP 200), désactive sinon";

    public function handle(): int
    {
        $limite = (int) $this->option('limite');

        $offres = OffreEmploi::where('statut', 'active')
            ->whereNotNull('source_url')
            ->orderBy('date_indexation') // vérifie d'abord les plus anciennes, jamais revérifiées récemment
            ->limit($limite)
            ->get();

        $ok = 0;
        $morts = 0;

        foreach ($offres as $offre) {
            try {
                $reponse = Http::withHeaders([
                    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                ])->timeout(8)->get($offre->source_url);

                if ($reponse->successful()) {
                    $ok++;
                } else {
                    $offre->update(['statut' => 'expiree']);
                    $morts++;
                    $this->warn("Lien mort ({$reponse->status()}) : {$offre->intitule} -> {$offre->source_url}");
                }
            } catch (\Throwable $e) {
                $offre->update(['statut' => 'expiree']);
                $morts++;
                $this->warn("Lien injoignable : {$offre->intitule} -> {$offre->source_url} ({$e->getMessage()})");
            }
        }

        $this->info("Vérifiés : {$offres->count()} | OK : {$ok} | Désactivés (lien mort) : {$morts}");

        return self::SUCCESS;
    }
}
