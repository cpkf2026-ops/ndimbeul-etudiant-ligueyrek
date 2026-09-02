<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProfilEtudiantResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        if (! $this->resource) {
            return [];
        }

        return [
            'universite_actuelle' => $this->universite_actuelle,
            'formation_actuelle' => $this->formation_actuelle,
            'niveau_actuel' => $this->niveau_actuel,
            'domaines_interets' => $this->domaines_interets,
            'recherche_stage' => $this->recherche_stage,
            'recherche_emploi' => $this->recherche_emploi,
        ];
    }
}
