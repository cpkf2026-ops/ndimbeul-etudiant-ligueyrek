<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UpdateFormationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('update', $this->route('formation')) ?? false;
    }

    public function rules(): array
    {
        return [
            'intitule' => ['sometimes', 'string', 'max:255'],
            'domaine' => ['sometimes', 'nullable', 'string', 'max:100'],
            'niveau' => ['sometimes', 'in:bts,licence,master,doctorat'],
            'duree_annees' => ['sometimes', 'nullable', 'integer', 'min:1', 'max:10'],
            'series_acceptees' => ['sometimes', 'nullable', 'array'],
            'moyenne_minimale' => ['sometimes', 'nullable', 'numeric', 'between:0,20'],
            'capacite' => ['sometimes', 'nullable', 'integer', 'min:0'],
            'prerequis' => ['sometimes', 'nullable', 'string'],
            'debouches' => ['sometimes', 'nullable', 'string'],
        ];
    }
}
