<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreFormationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('create', [\App\Models\Formation::class, $this->route('universite')?->id]) ?? false;
    }

    public function rules(): array
    {
        return [
            'intitule' => ['required', 'string', 'max:255'],
            'domaine' => ['nullable', 'string', 'max:100'],
            'niveau' => ['required', 'in:bts,licence,master,doctorat'],
            'duree_annees' => ['nullable', 'integer', 'min:1', 'max:10'],
            'series_acceptees' => ['nullable', 'array'],
            'moyenne_minimale' => ['nullable', 'numeric', 'between:0,20'],
            'capacite' => ['nullable', 'integer', 'min:0'],
            'prerequis' => ['nullable', 'string'],
            'debouches' => ['nullable', 'string'],
        ];
    }
}
