<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CacheReponse extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'cache_reponses';

    protected $fillable = [
        'question_hash', 'reponse_json', 'sources_utilisees',
        'date_expiration', 'nb_utilisations',
    ];

    protected function casts(): array
    {
        return [
            'reponse_json' => 'array',
            'sources_utilisees' => 'array',
            'date_expiration' => 'datetime',
        ];
    }

    public function estExpire(): bool
    {
        return $this->date_expiration !== null && $this->date_expiration->isPast();
    }

    public function incrementerUtilisation(): void
    {
        $this->increment('nb_utilisations');
    }
}
