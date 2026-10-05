<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ActualiteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'titre' => $this->titre,
            'contenu' => $this->contenu,
            'categorie' => $this->categorie,
            'source_url' => $this->source_url,
            // Image téléchargée localement par la veille IA (storage/app/public/actualites/,
            // voir pipeline.telecharger_image_locale côté Django) — servie via /media/...
            // avec CORS explicite, comme les logos d'établissements (voir UniversiteResource).
            'image_url' => $this->image_url && str_starts_with($this->image_url, '/storage/')
                ? url('/api/v1/media/' . substr($this->image_url, strlen('/storage/')))
                : $this->image_url,
            // Jour + heure réels si trouvés dans les métadonnées de l'article source
            // (extraire_metadonnees_article côté veille IA), sinon l'heure d'indexation.
            'date_publication' => $this->date_publication?->toIso8601String(),
            // Horodatage de l'indexation par la veille IA — distinct de date_publication,
            // gardé pour transparence même quand la date réelle a pu être trouvée.
            'date_indexation' => $this->created_at?->toIso8601String(),
            // Média / site officiel d'origine et fiabilité de la source (veille IA).
            'source' => $this->source_nom,
            'fiabilite' => $this->fiabilite,
            // Rédacteur si l'actualité a été écrite par un admin, sinon le média
            // d'origine — affiché tel quel sous l'article dans l'app.
            'auteur' => $this->relationLoaded('auteur') && $this->auteur
                ? $this->auteur->nom.' '.$this->auteur->prenom
                : $this->source_nom,
        ];
    }
}
