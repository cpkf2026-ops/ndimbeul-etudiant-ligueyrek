<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OffreEmploiResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'intitule' => $this->intitule,
            'entreprise' => $this->entreprise,
            'type' => $this->type,
            'domaine' => $this->domaine,
            'niveau_requis' => $this->niveau_requis,
            'region' => $this->region,
            'description' => $this->description,
            'source_url' => $this->source_url,
            'source' => $this->source,
            // Niveau de fiabilité de la source vérifié par la veille IA :
            // 'officiel' | 'presse' | 'plateforme' (null = offre non vérifiée).
            'fiabilite' => $this->fiabilite,
            'date_publication' => $this->date_publication?->toDateString(),
            'date_limite' => $this->date_limite?->toDateString(),
            // Horodatage précis (jour + heure) de l'indexation par la veille IA.
            'date_indexation' => $this->date_indexation?->toIso8601String(),
            'statut' => $this->statut,
            'expiree' => $this->estExpiree(),
            'est_favori' => $this->when(
                $request->user() !== null,
                fn () => $this->favoris()->where('utilisateur_id', $request->user()?->id)->exists()
            ),
        ];
    }
}
