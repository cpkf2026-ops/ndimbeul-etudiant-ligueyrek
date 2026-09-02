<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreSourceDonneeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('create', \App\Models\SourceDonnee::class) ?? false;
    }

    public function rules(): array
    {
        return [
            'universite_id' => ['nullable', 'uuid', 'exists:universites,id'],
            'type' => ['required', 'in:url,pdf,api'],
            'url_ou_chemin' => ['required', 'string', 'max:500'],
            'categorie' => ['nullable', 'string', 'max:100'],
        ];
    }
}
