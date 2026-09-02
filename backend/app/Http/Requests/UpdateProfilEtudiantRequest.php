<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfilEtudiantRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->estEtudiant() ?? false;
    }

    public function rules(): array
    {
        return [
            'universite_actuelle' => ['sometimes', 'nullable', 'string', 'max:255'],
            'formation_actuelle' => ['sometimes', 'nullable', 'string', 'max:255'],
            'niveau_actuel' => ['sometimes', 'nullable', 'in:L1,L2,L3,M1,M2,Doctorat'],
            'domaines_interets' => ['sometimes', 'nullable', 'array'],
            'recherche_stage' => ['sometimes', 'boolean'],
            'recherche_emploi' => ['sometimes', 'boolean'],
        ];
    }
}
