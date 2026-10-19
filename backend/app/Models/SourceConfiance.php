<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;

/**
 * Domaine de confiance utilisé par le service IA pour ses recherches Tavily
 * (include_domains). Lu par superapp_ia/services/sources.py.
 */
class SourceConfiance extends Model
{
    use HasUuid;

    protected $table = 'sources_confiance';

    protected $fillable = ['domaine', 'nom', 'categorie', 'actif'];

    protected function casts(): array
    {
        return ['actif' => 'boolean'];
    }
}
