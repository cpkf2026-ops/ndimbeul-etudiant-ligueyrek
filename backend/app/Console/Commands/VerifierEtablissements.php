<?php

namespace App\Console\Commands;

use App\Models\Universite;
use Illuminate\Console\Command;

/**
 * Tâche 1 du cahier des charges "développeur senior" : liste les établissements
 * actifs sans site officiel et/ou sans logo, pour prioriser les prochains lots
 * de recherche/vérification (batch suivant région par région).
 */
class VerifierEtablissements extends Command
{
    protected $signature = 'etablissements:verifier';
    protected $description = 'Liste les établissements actifs sans site officiel et/ou sans logo';

    public function handle(): int
    {
        $sansSite = Universite::where('statut_actif', true)
            ->where(fn ($q) => $q->whereNull('site_web_officiel')->orWhere('site_web_officiel', ''))
            ->orderBy('region')->orderBy('nom')
            ->get(['nom', 'code_unique', 'region']);

        $sansLogo = Universite::where('statut_actif', true)
            ->where(fn ($q) => $q->whereNull('image_url')->orWhere('image_url', ''))
            ->orderBy('region')->orderBy('nom')
            ->get(['nom', 'code_unique', 'region']);

        $parRegion = Universite::where('statut_actif', true)
            ->selectRaw('COALESCE(region, "(non renseignée)") as region, COUNT(*) as total')
            ->groupBy('region')
            ->orderBy('region')
            ->get();

        $this->info('=== Répartition par région ===');
        $this->table(['Région', 'Établissements'], $parRegion->map(fn ($r) => [$r->region, $r->total])->toArray());
        $this->newLine();

        $this->warn("=== Sans site officiel ({$sansSite->count()}) ===");
        $this->table(['Nom', 'Sigle', 'Région'], $sansSite->map(fn ($u) => [$u->nom, $u->code_unique, $u->region ?? '—'])->toArray());
        $this->newLine();

        $this->warn("=== Sans logo ({$sansLogo->count()}) ===");
        $this->table(['Nom', 'Sigle', 'Région'], $sansLogo->map(fn ($u) => [$u->nom, $u->code_unique, $u->region ?? '—'])->toArray());

        $total = Universite::where('statut_actif', true)->count();
        $this->newLine();
        $this->info("Total établissements actifs : {$total}");

        return self::SUCCESS;
    }
}
