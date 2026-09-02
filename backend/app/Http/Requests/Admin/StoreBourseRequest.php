<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreBourseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->aLeRole('super_admin', 'admin_etablissement') ?? false;
    }

    public function rules(): array
    {
        return [
            'nom' => ['required', 'string', 'max:255'],
            'organisme' => ['nullable', 'string', 'max:255'],
            'montant' => ['nullable', 'numeric', 'min:0'],
            'devise' => ['nullable', 'string', 'max:10'],
            'conditions' => ['nullable', 'string'],
            'demarches' => ['nullable', 'string'],
            'date_limite' => ['nullable', 'date'],
            'lien' => ['nullable', 'url', 'max:500'],
            'source' => ['nullable', 'string', 'max:255'],
        ];
    }
}
