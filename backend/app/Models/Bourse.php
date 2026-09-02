<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Bourse extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'bourses';

    protected $fillable = [
        'universite_id', 'nom', 'organisme', 'montant', 'devise', 'conditions',
        'demarches', 'date_limite', 'lien', 'source', 'date_maj',
    ];

    protected function casts(): array
    {
        return [
            'montant' => 'decimal:2',
            'date_limite' => 'date',
            'date_maj' => 'datetime',
        ];
    }

    public function universite(): BelongsTo
    {
        return $this->belongsTo(Universite::class, 'universite_id');
    }

    public function estExpiree(): bool
    {
        return $this->date_limite !== null && $this->date_limite->isPast();
    }
}
