<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ReinitialisationMotDePasse extends Notification
{
    use Queueable;

    public function __construct(private readonly string $lien) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Réinitialisation de votre mot de passe — Ndimbeul-Etudiant')
            ->greeting('Bonjour '.$notifiable->prenom.',')
            ->line('Vous avez demandé la réinitialisation de votre mot de passe.')
            ->action('Réinitialiser mon mot de passe', $this->lien)
            ->line('Ce lien expire dans 60 minutes. Si vous n\'êtes pas à l\'origine de cette demande, ignorez cet email.');
    }
}
