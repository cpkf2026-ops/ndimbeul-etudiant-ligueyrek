<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Table alimentée principalement par le service Django (managed=False côté Python).
 * Le modèle Laravel sert en lecture pour le back-office (listing, métriques).
 */
class DocumentRag extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'documents_rag';

    protected $fillable = [
        'source_id', 'titre', 'contenu_texte', 'nb_chunks',
        'date_indexation', 'version_embedding', 'vecteur_faiss_id',
    ];

    protected function casts(): array
    {
        return ['date_indexation' => 'datetime'];
    }

    public function source(): BelongsTo
    {
        return $this->belongsTo(SourceDonnee::class, 'source_id');
    }
}
