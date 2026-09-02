<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateUniversiteRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('update', $this->route('universite')) ?? false;
    }

    public function rules(): array
    {
        $universite = $this->route('universite');

        return [
            'nom' => ['sometimes', 'string', 'max:255'],
            'code_unique' => ['sometimes', 'string', 'max:50', Rule::unique('universites', 'code_unique')->ignore($universite?->id)],
            'region' => ['sometimes', 'nullable', 'string', 'max:100'],
            'commune' => ['sometimes', 'nullable', 'string', 'max:100'],
            'type' => ['sometimes', 'in:public,prive'],
            'site_web_officiel' => ['sometimes', 'nullable', 'url', 'max:255'],
            'description' => ['sometimes', 'nullable', 'string'],
            'image_url' => ['sometimes', 'nullable', 'url', 'max:500'],
            'email_contact' => ['sometimes', 'nullable', 'email', 'max:255'],
            'telephone_contact' => ['sometimes', 'nullable', 'string', 'max:30'],
            'statut_actif' => ['sometimes', 'boolean'],
        ];
    }
}
