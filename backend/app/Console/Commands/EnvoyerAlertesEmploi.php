<?php

namespace App\Console\Commands;

use App\Models\AlerteProfil;
use App\Models\OffreEmploi;
use App\Notifications\NouvelleOffreCorrespondante;
use Illuminate\Console\Command;

/**
 * CDC §8.3 "Alertes personnalisées : notification de l'étudiant lorsqu'une
 * nouvelle offre correspond à son profil." Compare les offres publiées depuis
 * la dernière exécution aux critères de chaque alerte active.
 */
class EnvoyerAlertesEmploi extends Command
{
    protected $signature = 'alertes:envoyer';
    protected $description = 'Notifie les étudiants dont une alerte correspond à une offre récente';

    public function handle(): int
    {
        $offresRecentes = OffreEmploi::actives()
            ->where('date_indexation', '>=', now()->subHour())
            ->get();

        if ($offresRecentes->isEmpty()) {
            $this->info('Aucune nouvelle offre depuis la dernière exécution.');

            return self::SUCCESS;
        }

        $alertes = AlerteProfil::where('actif', true)->with('utilisateur')->get();
        $nbNotifications = 0;

        foreach ($alertes as $alerte) {
            $offresCorrespondantes = $offresRecentes->filter(fn ($offre) => $alerte->correspondA($offre));

            if ($offresCorrespondantes->isNotEmpty() && $alerte->utilisateur) {
                $alerte->utilisateur->notify(new NouvelleOffreCorrespondante($offresCorrespondantes));
                $alerte->update(['derniere_notification_le' => now()]);
                $nbNotifications++;
            }
        }

        $this->info("{$nbNotifications} alerte(s) déclenchée(s).");

        return self::SUCCESS;
    }
}
