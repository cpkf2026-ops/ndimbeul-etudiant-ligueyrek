<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FraisScolariteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'universite_id' => $this->universite_id,
            'formation_id' => $this->formation_id,
            'montant' => $this->montant,
            'devise' => $this->devise,
            'echeancier' => $this->echeancier,
            'moyens_paiement' => $this->moyens_paiement,
            'source' => $this->source,
            'date_maj' => $this->date_maj?->toIso8601String(),
        ];
    }
}
