<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UniversiteSuivie extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'universites_suivies';
    public $timestamps = false;

    protected $fillable = ['utilisateur_id', 'universite_id', 'statut', 'score_matching', 'date_ajout'];

    protected function casts(): array
    {
        return [
            'score_matching' => 'decimal:2',
            'date_ajout' => 'datetime',
        ];
    }

    public function utilisateur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'utilisateur_id');
    }

    public function universite(): BelongsTo
    {
        return $this->belongsTo(Universite::class, 'universite_id');
    }
}
