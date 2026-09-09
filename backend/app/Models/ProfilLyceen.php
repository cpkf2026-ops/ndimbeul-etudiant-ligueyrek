<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProfilLyceen extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'profils_lyceens';

    protected $fillable = [
        'utilisateur_id', 'serie_bac', 'niveau', 'etablissement', 'moyenne_generale', 'passions',
        'metiers_envisages', 'budget_max_annuel', 'mobilite',
        'pref_public_prive', 'region_cible', 'annee_terminale',
    ];

    protected function casts(): array
    {
        return [
            'passions' => 'array',
            'metiers_envisages' => 'array',
            'budget_max_annuel' => 'decimal:2',
            'moyenne_generale' => 'decimal:2',
            'mobilite' => 'boolean',
        ];
    }

    public function utilisateur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'utilisateur_id');
    }

    /**
     * Taux de complétude du profil (0-100), utilisé par Flutter pour la barre de progression.
     */
    public function calculerCompletude(): int
    {
        $champs = [
            'serie_bac', 'niveau', 'etablissement', 'moyenne_generale', 'passions', 'metiers_envisages',
            'budget_max_annuel', 'pref_public_prive', 'region_cible', 'annee_terminale',
        ];

        $remplis = collect($champs)->filter(fn ($champ) => filled($this->{$champ}))->count();

        return (int) round(($remplis / count($champs)) * 100);
    }

    public function estComplet(): bool
    {
        return $this->calculerCompletude() === 100;
    }

    /**
     * Payload envoyé à Django /internal/recommendations.
     */
    public function versProfilPourIa(): array
    {
        return [
            'serie_bac' => $this->serie_bac,
            'moyenne_generale' => $this->moyenne_generale,
            'budget_max' => $this->budget_max_annuel,
            'mobilite' => $this->mobilite,
            'pref_public_prive' => $this->pref_public_prive,
            'region_cible' => $this->region_cible,
            'passions' => $this->passions ?? [],
            'metiers_envisages' => $this->metiers_envisages ?? [],
        ];
    }
}
