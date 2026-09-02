<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FormationFavorite extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'formations_favorites';
    public $timestamps = false;

    protected $fillable = ['utilisateur_id', 'formation_id', 'date_sauvegarde', 'notes_perso'];

    protected function casts(): array
    {
        return ['date_sauvegarde' => 'datetime'];
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
