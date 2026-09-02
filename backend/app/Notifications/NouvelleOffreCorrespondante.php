<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Collection;

class NouvelleOffreCorrespondante extends Notification
{
    use Queueable;

    public function __construct(private readonly Collection $offres) {}

    /**
     * 'database' alimente la table `notifications` consultée par Flutter (in-app),
     * 'mail' envoie en complément un email (CDC §3 "notifications").
     */
    public function via(object $notifiable): array
    {
        return ['database', 'mail'];
    }

    public function toArray(object $notifiable): array
    {
        return [
            'type' => 'nouvelle_offre',
            'nb_offres' => $this->offres->count(),
            'offres' => $this->offres->map(fn ($o) => ['id' => $o->id, 'intitule' => $o->intitule, 'entreprise' => $o->entreprise])->all(),
        ];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $message = (new MailMessage)
            ->subject('Nouvelles opportunités correspondant à votre profil')
            ->greeting('Bonjour '.$notifiable->prenom.',');

        foreach ($this->offres as $offre) {
            $message->line("- {$offre->intitule} chez {$offre->entreprise} ({$offre->region})");
        }

        return $message->line('Consultez-les dès maintenant dans l\'application.');
    }
}
