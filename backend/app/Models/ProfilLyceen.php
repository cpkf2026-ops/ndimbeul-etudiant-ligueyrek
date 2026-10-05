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
        'matieres_fortes', 'metiers_envisages', 'mobilite',
        'pref_public_prive', 'region_cible', 'annee_terminale',
    ];

    protected function casts(): array
    {
        return [
            'passions' => 'array',
            'matieres_fortes' => 'array',
            'metiers_envisages' => 'array',
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
            'serie_bac', 'niveau', 'etablissement', 'moyenne_generale', 'passions', 'matieres_fortes',
            'metiers_envisages', 'pref_public_prive', 'region_cible', 'annee_terminale',
        ];

        $remplis = collect($champs)->filter(fn ($champ) => filled($this->{$champ}))->count();

        return (int) round(($remplis / count($champs)) * 100);
    }

    /** En-dessous de ce seuil, le profil est jugé trop incomplet pour des recommandations
     * fiables ; au-delà, on recommande sur la base de ce qui est renseigné plutôt que
     * d'exiger 100% (quelques champs facultatifs manquants ne doivent pas tout bloquer). */
    private const SEUIL_COMPLETUDE_MINIMUM = 70;

    public function estComplet(): bool
    {
        return $this->calculerCompletude() >= self::SEUIL_COMPLETUDE_MINIMUM;
    }

    /**
     * Payload envoyé à Django /internal/recommendations.
     */
    public function versProfilPourIa(): array
    {
        return [
            'serie_bac' => $this->serie_bac,
            'moyenne_generale' => $this->moyenne_generale,
            'mobilite' => $this->mobilite,
            'pref_public_prive' => $this->pref_public_prive,
            'region_cible' => $this->region_cible,
            'passions' => $this->passions ?? [],
            'matieres_fortes' => $this->matieres_fortes ?? [],
            'metiers_envisages' => $this->metiers_envisages ?? [],
        ];
    }
}
