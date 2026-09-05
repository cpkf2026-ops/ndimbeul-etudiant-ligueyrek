<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProfilDiplomeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        if (! $this->resource) {
            return [];
        }

        return [
            'dernier_diplome' => $this->dernier_diplome,
            'domaine' => $this->domaine,
            'situation_actuelle' => $this->situation_actuelle,
            'entreprise' => $this->entreprise,
        ];
    }
}
