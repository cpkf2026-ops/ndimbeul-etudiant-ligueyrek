<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ActualiteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'titre' => $this->titre,
            'contenu' => $this->contenu,
            'categorie' => $this->categorie,
            'source_url' => $this->source_url,
            'image_url' => $this->image_url,
            'date_publication' => $this->date_publication?->toDateString(),
            'auteur' => $this->whenLoaded('auteur', fn () => $this->auteur->nom.' '.$this->auteur->prenom),
        ];
    }
}
