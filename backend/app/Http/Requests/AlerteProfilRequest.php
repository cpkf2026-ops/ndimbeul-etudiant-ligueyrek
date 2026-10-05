<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AlerteProfilRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'criteres' => ['required', 'array'],
            'criteres.domaine' => ['sometimes', 'nullable', 'string'],
            'criteres.region' => ['sometimes', 'nullable', 'string'],
            'criteres.type' => ['sometimes', 'nullable', 'in:emploi,stage,alternance,formation,bourse,concours'],
            'criteres.niveau' => ['sometimes', 'nullable', 'string'],
            'actif' => ['sometimes', 'boolean'],
        ];
    }
}
