<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AlerteProfilResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'criteres' => $this->criteres,
            'actif' => $this->actif,
            'derniere_notification_le' => $this->derniere_notification_le?->toIso8601String(),
            'date_creation' => $this->created_at?->toIso8601String(),
        ];
    }
}
