<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Actualite extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'actualites';

    protected $fillable = [
        'titre', 'contenu', 'auteur_id', 'categorie', 'source_url',
        'image_url', 'date_publication', 'cible_roles', 'statut',
    ];

    protected function casts(): array
    {
        return [
            'cible_roles' => 'array',
            'date_publication' => 'date',
        ];
    }

    public function auteur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'auteur_id');
    }

    public function estCiblePour(string $role): bool
    {
        return empty($this->cible_roles) || in_array($role, $this->cible_roles, true);
    }

    public function scopePubliees($query)
    {
        return $query->where('statut', 'publie');
    }
}
