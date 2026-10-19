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
            // Un logo local (Tâche 2 : téléchargé dans storage/app/public/logos/, voir
            // TelechargerLogos) est stocké en chemin relatif ("/storage/logos/x.png") —
            // servi via /api/v1/media/... (et non /storage/... directement) car ce
            // dernier est renvoyé par le serveur de dev comme fichier statique brut,
            // sans en-tête CORS, ce que le renderer web de Flutter refuse de décoder.
            // Un logo pas encore migré (URL distante http(s)://...) ou absent (null)
            // passe tel quel.
            'image_url' => $this->image_url && str_starts_with($this->image_url, '/storage/')
                ? url('/api/v1/media/' . substr($this->image_url, strlen('/storage/')))
                : $this->image_url,
            'contact' => [
                'email' => $this->email_contact,
                'telephone' => $this->telephone_contact,
                'adresse' => $this->adresse,
            ],
            // Fiche enrichie (établissements sans site surtout) : infos publiques collectées
            // par le service IA, avec la page d'où elles viennent.
            'domaines' => $this->domaines ?? [],
            'diplomes' => $this->diplomes ?? [],
            'admission' => $this->admission,
            'niveau_requis' => $this->niveau_requis ?? [],
            'pieces_a_fournir' => $this->pieces_a_fournir ?? [],
            'source_infos' => $this->source_infos,
            // Fiche complète (CDC §5.3/§7.3) : chargée uniquement si demandée explicitement (show),
            // pas sur la liste, pour ne pas alourdir /api/v1/universities.
            'formations' => FormationResource::collection($this->whenLoaded('formations')),
            'bourses' => BourseResource::collection($this->whenLoaded('bourses')),
            'logements' => LogementResource::collection($this->whenLoaded('logements')),
            'frais_scolarite' => FraisScolariteResource::collection($this->whenLoaded('fraisScolarite')),
        ];
    }
}
