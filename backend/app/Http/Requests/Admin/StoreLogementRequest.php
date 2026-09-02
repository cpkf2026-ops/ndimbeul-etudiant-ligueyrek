<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreLogementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->aLeRole('super_admin', 'admin_etablissement') ?? false;
    }

    public function rules(): array
    {
        return [
            'nom' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:residence,foyer,partenaire'],
            'capacite' => ['nullable', 'integer', 'min:0'],
            'tarif_mensuel' => ['nullable', 'numeric', 'min:0'],
            'devise' => ['nullable', 'string', 'max:10'],
            'contact' => ['nullable', 'string', 'max:255'],
            'source' => ['nullable', 'string', 'max:255'],
        ];
    }
}
