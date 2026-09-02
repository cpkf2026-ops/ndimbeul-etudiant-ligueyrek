<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SourceDonneeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'universite_id' => $this->universite_id,
            'type' => $this->type,
            'url_ou_chemin' => $this->url_ou_chemin,
            'categorie' => $this->categorie,
            'statut' => $this->statut,
            'derniere_erreur' => $this->derniere_erreur,
            'date_dernier_crawl' => $this->date_dernier_crawl?->toIso8601String(),
        ];
    }
}
