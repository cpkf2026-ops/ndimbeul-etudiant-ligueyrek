<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OffreFavorite extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'offres_favorites';
    public $timestamps = false;

    protected $fillable = ['utilisateur_id', 'offre_id', 'date_sauvegarde'];

    protected function casts(): array
    {
        return ['date_sauvegarde' => 'datetime'];
    }

    public function utilisateur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'utilisateur_id');
    }

    public function offre(): BelongsTo
    {
        return $this->belongsTo(OffreEmploi::class, 'offre_id');
    }
}
