<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreFraisScolariteRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->aLeRole('super_admin', 'admin_etablissement') ?? false;
    }

    public function rules(): array
    {
        return [
            'formation_id' => ['nullable', 'uuid', 'exists:formations,id'],
            'montant' => ['required', 'numeric', 'min:0'],
            'devise' => ['nullable', 'string', 'max:10'],
            'echeancier' => ['nullable', 'array'],
            'moyens_paiement' => ['nullable', 'array'],
            'source' => ['nullable', 'string', 'max:255'],
        ];
    }
}
