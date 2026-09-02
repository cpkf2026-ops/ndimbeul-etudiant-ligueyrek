<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SourceDonnee extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'sources_donnees';

    protected $fillable = [
        'universite_id', 'admin_id', 'type', 'url_ou_chemin', 'categorie',
        'date_dernier_crawl', 'statut', 'derniere_erreur',
    ];

    protected function casts(): array
    {
        return ['date_dernier_crawl' => 'datetime'];
    }

    public function universite(): BelongsTo
    {
        return $this->belongsTo(Universite::class, 'universite_id');
    }

    public function admin(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'admin_id');
    }

    public function documentsRag(): HasMany
    {
        return $this->hasMany(DocumentRag::class, 'source_id');
    }

    public function marquerEnErreur(string $raison): void
    {
        $this->update(['statut' => 'erreur', 'derniere_erreur' => $raison]);
    }

    public function verifierFraicheur(int $moisLimite = 3): bool
    {
        return $this->date_dernier_crawl !== null
            && $this->date_dernier_crawl->diffInMonths(now()) <= $moisLimite;
    }
}
