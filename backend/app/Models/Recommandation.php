<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Table alimentée par Django (moteur de scoring). Lecture seule côté Laravel.
 */
class Recommandation extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'recommandations';
    public $timestamps = false;

    protected $fillable = [
        'utilisateur_id', 'formation_id', 'score_correspondance',
        'explication_llm', 'sources_infos', 'date_generation',
    ];

    protected function casts(): array
    {
        return [
            'score_correspondance' => 'decimal:2',
            'sources_infos' => 'array',
            'date_generation' => 'datetime',
        ];
    }

    public function utilisateur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'utilisateur_id');
    }

    public function formation(): BelongsTo
    {
        return $this->belongsTo(Formation::class, 'formation_id');
    }
}
