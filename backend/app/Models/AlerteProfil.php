<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AlerteProfil extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'alertes_profil';

    protected $fillable = ['utilisateur_id', 'criteres', 'actif', 'derniere_notification_le'];

    protected function casts(): array
    {
        return [
            'criteres' => 'array',
            'actif' => 'boolean',
            'derniere_notification_le' => 'datetime',
        ];
    }

    public function utilisateur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'utilisateur_id');
    }

    /**
     * Vérifie si une offre d'emploi correspond aux critères de l'alerte.
     * Utilisé par la tâche planifiée de notification (voir Console\Commands).
     */
    public function correspondA(OffreEmploi $offre): bool
    {
        $c = $this->criteres;

        if (! empty($c['domaine']) && $offre->domaine !== $c['domaine']) {
            return false;
        }
        if (! empty($c['region']) && $offre->region !== $c['region']) {
            return false;
        }
        if (! empty($c['type']) && $offre->type !== $c['type']) {
            return false;
        }

        return true;
    }
}
