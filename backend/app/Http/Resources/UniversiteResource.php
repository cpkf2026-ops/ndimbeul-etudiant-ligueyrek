<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UniversiteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'nom' => $this->nom,
            'code_unique' => $this->code_unique,
            'region' => $this->region,
            'commune' => $this->commune,
            'type' => $this->type,
            'site_web_officiel' => $this->site_web_officiel,
            'description' => $this->description,
            'image_url' => $this->image_url,
            'contact' => [
                'email' => $this->email_contact,
                'telephone' => $this->telephone_contact,
            ],
            // Fiche complète (CDC §5.3/§7.3) : chargée uniquement si demandée explicitement (show),
            // pas sur la liste, pour ne pas alourdir /api/v1/universities.
            'formations' => FormationResource::collection($this->whenLoaded('formations')),
            'bourses' => BourseResource::collection($this->whenLoaded('bourses')),
            'logements' => LogementResource::collection($this->whenLoaded('logements')),
            'frais_scolarite' => FraisScolariteResource::collection($this->whenLoaded('fraisScolarite')),
        ];
    }
}
