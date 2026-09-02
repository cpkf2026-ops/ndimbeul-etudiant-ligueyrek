<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class OffreEmploi extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'offres_emploi';

    protected $fillable = [
        'intitule', 'entreprise', 'type', 'domaine', 'niveau_requis', 'region',
        'description', 'source_url', 'source', 'date_publication', 'date_limite',
        'statut', 'date_indexation',
    ];

    protected function casts(): array
    {
        return [
            'date_publication' => 'date',
            'date_limite' => 'date',
            'date_indexation' => 'datetime',
        ];
    }

    public function favoris(): HasMany
    {
        return $this->hasMany(OffreFavorite::class, 'offre_id');
    }

    public function estExpiree(): bool
    {
        return $this->statut === 'expiree'
            || ($this->date_limite !== null && $this->date_limite->isPast());
    }

    public function scopeActives($query)
    {
        return $query->where('statut', 'active');
    }

    public function scopeDansDomaine($query, ?string $domaine)
    {
        return $domaine ? $query->where('domaine', $domaine) : $query;
    }

    public function scopeDansRegion($query, ?string $region)
    {
        return $region ? $query->where('region', $region) : $query;
    }

    public function scopeDeType($query, ?string $type)
    {
        return $type ? $query->where('type', $type) : $query;
    }
}
