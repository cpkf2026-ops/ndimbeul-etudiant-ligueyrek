<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Formation extends Model
{
    use HasFactory, HasUuid, SoftDeletes;

    protected $table = 'formations';

    protected $fillable = [
        'universite_id', 'intitule', 'domaine', 'niveau', 'duree_annees',
        'series_acceptees', 'moyenne_minimale', 'capacite', 'prerequis', 'debouches',
    ];

    protected function casts(): array
    {
        return [
            'series_acceptees' => 'array',
            'moyenne_minimale' => 'decimal:2',
        ];
    }

    public function universite(): BelongsTo
    {
        return $this->belongsTo(Universite::class, 'universite_id');
    }

    public function fraisScolarite(): HasMany
    {
        return $this->hasMany(FraisScolarite::class, 'formation_id');
    }

    public function favorisPar(): HasMany
    {
        return $this->hasMany(FormationFavorite::class, 'formation_id');
    }

    public function recommandations(): HasMany
    {
        return $this->hasMany(Recommandation::class, 'formation_id');
    }

    /**
     * Vérifie qu'une série de bac donnée est acceptée par la formation.
     * Utilisé côté API pour un filtre rapide sans dépendre du moteur IA.
     */
    public function estCompatibleSerie(?string $serie): bool
    {
        if (! $serie || empty($this->series_acceptees)) {
            return true;
        }

        return in_array($serie, $this->series_acceptees, true);
    }

    public function scopeDansDomaine($query, ?string $domaine)
    {
        return $domaine ? $query->where('domaine', $domaine) : $query;
    }

    public function scopeDeNiveau($query, ?string $niveau)
    {
        return $niveau ? $query->where('niveau', $niveau) : $query;
    }
}
