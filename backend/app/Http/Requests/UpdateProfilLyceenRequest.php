<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfilLyceenRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->estLyceen() ?? false;
    }

    public function rules(): array
    {
        return [
            'serie_bac' => ['sometimes', 'string', 'max:10'],
            'niveau' => ['sometimes', 'nullable', 'in:seconde,premiere,terminale'],
            'etablissement' => ['sometimes', 'nullable', 'string', 'max:255'],
            'moyenne_generale' => ['sometimes', 'nullable', 'numeric', 'between:0,20'],
            'passions' => ['sometimes', 'nullable', 'array'],
            'matieres_fortes' => ['sometimes', 'nullable', 'array'],
            'metiers_envisages' => ['sometimes', 'nullable', 'array'],
            'mobilite' => ['sometimes', 'boolean'],
            'pref_public_prive' => ['sometimes', 'in:public,prive,indifferent'],
            'region_cible' => ['sometimes', 'nullable', 'string', 'max:100'],
            'annee_terminale' => ['sometimes', 'nullable', 'integer', 'min:2020', 'max:2100'],
        ];
    }
}
