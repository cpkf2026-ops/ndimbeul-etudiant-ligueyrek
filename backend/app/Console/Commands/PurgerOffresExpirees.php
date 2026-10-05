<?php

namespace App\Console\Commands;

use App\Models\OffreEmploi;
use Illuminate\Console\Command;

/**
 * CDC §8.1 : "Suppression automatique des annonces expirées".
 * On ne supprime pas physiquement (traçabilité), on marque "expiree".
 *
 * Tâche 5 : en plus de la date limite explicite, une offre de plus de 60 jours
 * depuis son indexation est masquée automatiquement même sans date limite connue
 * (une offre "active" affichée depuis 2 mois sans confirmation est peu fiable).
 */
class PurgerOffresExpirees extends Command
{
    private const JOURS_MAX_SANS_DATE_LIMITE = 60;

    protected $signature = 'offres:purger-expirees';
    protected $description = 'Marque comme expirées les offres dont la date limite est dépassée ou qui datent de plus de 60 jours';

    public function handle(): int
    {
        $nbDateLimite = OffreEmploi::where('statut', 'active')
            ->whereNotNull('date_limite')
            ->where('date_limite', '<', now())
            ->update(['statut' => 'expiree']);

        $nbAnciennete = OffreEmploi::where('statut', 'active')
            ->where('date_indexation', '<', now()->subDays(self::JOURS_MAX_SANS_DATE_LIMITE))
            ->update(['statut' => 'expiree']);

        $this->info("{$nbDateLimite} offre(s) expirée(s) par date limite dépassée.");
        $this->info("{$nbAnciennete} offre(s) expirée(s) car indexées il y a plus de ".self::JOURS_MAX_SANS_DATE_LIMITE.' jours.');

        return self::SUCCESS;
    }
}
