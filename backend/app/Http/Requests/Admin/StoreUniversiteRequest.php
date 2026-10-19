<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreUniversiteRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('create', \App\Models\Universite::class) ?? false;
    }

    public function rules(): array
    {
        return [
            'nom' => ['required', 'string', 'max:255'],
            'code_unique' => ['required', 'string', 'max:50', 'unique:universites,code_unique'],
            'region' => ['nullable', 'string', 'max:100'],
            'commune' => ['nullable', 'string', 'max:100'],
            'type' => ['nullable', 'in:public,prive'],
            'site_web_officiel' => ['nullable', 'url', 'max:255'],
            'description' => ['nullable', 'string'],
            'image_url' => ['nullable', 'url', 'max:500'],
            'email_contact' => ['nullable', 'email', 'max:255'],
            'telephone_contact' => ['nullable', 'string', 'max:30'],
            'statut_actif' => ['sometimes', 'boolean'],
        ];
    }
}
