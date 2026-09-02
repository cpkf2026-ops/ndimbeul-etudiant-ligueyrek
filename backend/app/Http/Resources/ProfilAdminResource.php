<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProfilAdminResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        if (! $this->resource) {
            return [];
        }

        return [
            'niveau_acces' => $this->niveau_acces,
            'universite_id' => $this->universite_id,
            'organisation' => $this->organisation,
            'contact_pro' => $this->contact_pro,
            'permissions' => $this->permissions,
            'date_prise_fonction' => $this->date_prise_fonction?->toDateString(),
        ];
    }
}
