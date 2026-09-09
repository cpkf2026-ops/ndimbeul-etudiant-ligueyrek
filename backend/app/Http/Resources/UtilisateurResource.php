<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UtilisateurResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'nom' => $this->nom,
            'prenom' => $this->prenom,
            'email' => $this->email,
            'role' => $this->role,
            'region' => $this->region,
            'statut' => $this->statut,
            'profil_complete' => $this->profil_complete,
            'date_inscription' => $this->created_at?->toIso8601String(),
            'date_derniere_connexion' => $this->date_derniere_connexion?->toIso8601String(),
            'profil' => match ($this->role) {
                'lyceen' => new ProfilLyceenResource($this->whenLoaded('profilLyceen')),
                'etudiant' => new ProfilEtudiantResource($this->whenLoaded('profilEtudiant')),
                'diplome' => new ProfilDiplomeResource($this->whenLoaded('profilDiplome')),
                'admin_etablissement', 'super_admin' => new ProfilAdminResource($this->whenLoaded('profilAdmin')),
                default => null,
            },
        ];
    }
}
