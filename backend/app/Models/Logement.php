<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Logement extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'logements';

    protected $fillable = [
        'universite_id', 'nom', 'type', 'capacite', 'tarif_mensuel',
        'devise', 'contact', 'source', 'date_maj',
    ];

    protected function casts(): array
    {
        return [
            'tarif_mensuel' => 'decimal:2',
            'date_maj' => 'datetime',
        ];
    }

    public function universite(): BelongsTo
    {
        return $this->belongsTo(Universite::class, 'universite_id');
    }
}
