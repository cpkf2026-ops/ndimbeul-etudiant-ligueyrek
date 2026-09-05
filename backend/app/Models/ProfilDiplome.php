<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProfilDiplome extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'profils_diplomes';

    protected $fillable = [
        'utilisateur_id', 'dernier_diplome', 'domaine', 'situation_actuelle', 'entreprise',
    ];

    public function utilisateur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'utilisateur_id');
    }
}
