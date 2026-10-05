<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BourseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'universite_id' => $this->universite_id,
            'nom' => $this->nom,
            'organisme' => $this->organisme,
            // Cast Eloquent 'decimal:2' -> chaîne PHP : reconverti en number JSON (Flutter
            // caste `as num?`, qui échoue sur une chaîne, voir ProfilLyceenResource).
            'montant' => $this->montant !== null ? (float) $this->montant : null,
            'devise' => $this->devise,
            'conditions' => $this->conditions,
            'demarches' => $this->demarches,
            'date_limite' => $this->date_limite?->toDateString(),
            'expiree' => $this->estExpiree(),
            'lien' => $this->lien,
            'source' => $this->source,
            'date_maj' => $this->date_maj?->toIso8601String(),
        ];
    }
}
