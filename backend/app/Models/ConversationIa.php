<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ConversationIa extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'conversations_ia';

    protected $fillable = ['utilisateur_id', 'messages', 'date_derniere_activite'];

    protected function casts(): array
    {
        return [
            'messages' => 'array',
            'date_derniere_activite' => 'datetime',
        ];
    }

    public function utilisateur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'utilisateur_id');
    }

    public function ajouterMessage(string $role, string $contenu, array $sources = []): void
    {
        $messages = $this->messages ?? [];
        $messages[] = [
            'role' => $role,
            'contenu' => $contenu,
            'sources' => $sources,
            'date' => now()->toIso8601String(),
        ];

        $this->update([
            'messages' => $messages,
            'date_derniere_activite' => now(),
        ]);
    }

    public function obtenirContexte(int $n = 10): array
    {
        return collect($this->messages ?? [])->take(-$n)->values()->all();
    }
}
