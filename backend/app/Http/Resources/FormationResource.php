<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FormationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'universite_id' => $this->universite_id,
            'universite_nom' => $this->whenLoaded('universite', fn () => $this->universite->nom),
            'intitule' => $this->intitule,
            'domaine' => $this->domaine,
            'niveau' => $this->niveau,
            'duree_annees' => $this->duree_annees,
            'series_acceptees' => $this->series_acceptees,
            // Cast Eloquent 'decimal:2' -> chaîne PHP : reconverti en number JSON.
            'moyenne_minimale' => $this->moyenne_minimale !== null ? (float) $this->moyenne_minimale : null,
            'capacite' => $this->capacite,
            'prerequis' => $this->prerequis,
            'debouches' => $this->debouches,
            'est_favori' => $this->when(
                $request->user() !== null,
                fn () => $this->favorisPar()->where('utilisateur_id', $request->user()?->id)->exists()
            ),
        ];
    }
}
