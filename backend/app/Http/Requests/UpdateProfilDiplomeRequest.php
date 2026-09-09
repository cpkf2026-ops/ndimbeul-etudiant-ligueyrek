<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfilDiplomeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->estDiplome() ?? false;
    }

    public function rules(): array
    {
        return [
            'dernier_diplome' => ['sometimes', 'string', 'max:255'],
            'domaine' => ['sometimes', 'nullable', 'string', 'max:255'],
            'situation_actuelle' => ['sometimes', 'in:en_poste,recherche_emploi,stage'],
            'entreprise' => ['sometimes', 'nullable', 'string', 'max:255'],
        ];
    }
}
