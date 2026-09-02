<?php

namespace App\Console\Commands;

use App\Models\OffreEmploi;
use Illuminate\Console\Command;

/**
 * CDC §8.1 : "Suppression automatique des annonces expirées".
 * On ne supprime pas physiquement (traçabilité), on marque "expiree".
 */
class PurgerOffresExpirees extends Command
{
    protected $signature = 'offres:purger-expirees';
    protected $description = 'Marque comme expirées les offres dont la date limite est dépassée';

    public function handle(): int
    {
        $nb = OffreEmploi::where('statut', 'active')
            ->whereNotNull('date_limite')
            ->where('date_limite', '<', now())
            ->update(['statut' => 'expiree']);

        $this->info("{$nb} offre(s) marquée(s) comme expirée(s).");

        return self::SUCCESS;
    }
}
