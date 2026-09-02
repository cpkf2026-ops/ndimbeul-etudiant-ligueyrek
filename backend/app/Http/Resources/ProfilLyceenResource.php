<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProfilLyceenResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        if (! $this->resource) {
            return [];
        }

        return [
            'serie_bac' => $this->serie_bac,
            'moyenne_generale' => $this->moyenne_generale,
            'passions' => $this->passions,
            'metiers_envisages' => $this->metiers_envisages,
            'budget_max_annuel' => $this->budget_max_annuel,
            'mobilite' => $this->mobilite,
            'pref_public_prive' => $this->pref_public_prive,
            'region_cible' => $this->region_cible,
            'annee_terminale' => $this->annee_terminale,
            'completude' => $this->calculerCompletude(),
        ];
    }
}
