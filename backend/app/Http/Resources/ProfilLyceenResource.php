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
            'niveau' => $this->niveau,
            'etablissement' => $this->etablissement,
            // Le cast Eloquent 'decimal:2' renvoie une chaîne ("14.50") pour préserver la
            // précision — on la reconvertit en nombre ici pour que le JSON soit un vrai
            // number côté API (Flutter caste `as num?`, qui échoue sur une chaîne).
            'moyenne_generale' => $this->moyenne_generale !== null ? (float) $this->moyenne_generale : null,
            'passions' => $this->passions,
            'matieres_fortes' => $this->matieres_fortes,
            'metiers_envisages' => $this->metiers_envisages,
            'mobilite' => $this->mobilite,
            'pref_public_prive' => $this->pref_public_prive,
            'region_cible' => $this->region_cible,
            'annee_terminale' => $this->annee_terminale,
            'completude' => $this->calculerCompletude(),
        ];
    }
}
