<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LogementResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'universite_id' => $this->universite_id,
            'nom' => $this->nom,
            'type' => $this->type,
            'capacite' => $this->capacite,
            'tarif_mensuel' => $this->tarif_mensuel,
            'devise' => $this->devise,
            'contact' => $this->contact,
            'source' => $this->source,
            'date_maj' => $this->date_maj?->toIso8601String(),
        ];
    }
}
