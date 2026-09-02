<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\Utilisateur;
use Illuminate\Http\Request;

/**
 * Centralise la journalisation des actions sensibles (CDC §3.3 "Journalisation
 * des accès et des actions sensibles pour audit"). Appelé depuis les contrôleurs
 * d'administration et depuis les événements d'authentification.
 */
class AuditLogger
{
    public function log(
        ?Utilisateur $utilisateur,
        string $action,
        ?string $entite = null,
        ?string $entiteId = null,
        ?array $avant = null,
        ?array $apres = null,
    ): AuditLog {
        return AuditLog::create([
            'utilisateur_id' => $utilisateur?->id,
            'action' => $action,
            'entite_modifiee' => $entite,
            'entite_id' => $entiteId,
            'donnees_avant' => $avant,
            'donnees_apres' => $apres,
            'ip_source' => request()->ip(),
            'date_action' => now(),
        ]);
    }

    public function connexion(Utilisateur $utilisateur): AuditLog
    {
        return $this->log($utilisateur, 'login');
    }

    public function deconnexion(Utilisateur $utilisateur): AuditLog
    {
        return $this->log($utilisateur, 'logout');
    }

    public function changementRole(Utilisateur $acteur, Utilisateur $cible, string $ancienRole, string $nouveauRole): AuditLog
    {
        return $this->log(
            $acteur,
            'role_change',
            'utilisateurs',
            $cible->id,
            ['role' => $ancienRole],
            ['role' => $nouveauRole],
        );
    }
}
