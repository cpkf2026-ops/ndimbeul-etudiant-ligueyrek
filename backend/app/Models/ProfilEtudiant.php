<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProfilEtudiant extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'profils_etudiants';

    protected $fillable = [
        'utilisateur_id', 'universite_actuelle', 'formation_actuelle',
        'niveau_actuel', 'domaines_interets', 'recherche_stage', 'recherche_emploi',
    ];

    protected function casts(): array
    {
        return [
            'domaines_interets' => 'array',
            'recherche_stage' => 'boolean',
            'recherche_emploi' => 'boolean',
        ];
    }

    public function utilisateur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'utilisateur_id');
    }

    public function chercheStageOuEmploi(): bool
    {
        return $this->recherche_stage || $this->recherche_emploi;
    }
}
