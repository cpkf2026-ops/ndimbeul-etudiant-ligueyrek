<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;

/**
 * Consommation journalière de crédits Tavily, écrite par le service IA
 * (superapp_ia/services/credits.py). Lecture seule côté Laravel.
 */
class CreditTavily extends Model
{
    use HasUuid;

    protected $table = 'credits_tavily';

    protected $fillable = ['jour', 'credits_veille', 'credits_interactif', 'nb_requetes'];

    protected function casts(): array
    {
        return ['jour' => 'date'];
    }
}
