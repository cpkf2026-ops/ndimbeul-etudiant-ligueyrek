<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FraisScolarite extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'frais_scolarite';

    protected $fillable = [
        'universite_id', 'formation_id', 'montant', 'devise', 'echeancier',
        'moyens_paiement', 'source', 'date_maj',
    ];

    protected function casts(): array
    {
        return [
            'montant' => 'decimal:2',
            'echeancier' => 'array',
            'moyens_paiement' => 'array',
            'date_maj' => 'datetime',
        ];
    }

    public function universite(): BelongsTo
    {
        return $this->belongsTo(Universite::class, 'universite_id');
    }

    public function formation(): BelongsTo
    {
        return $this->belongsTo(Formation::class, 'formation_id');
    }
}
