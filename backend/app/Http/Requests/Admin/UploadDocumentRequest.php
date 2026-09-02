<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UploadDocumentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->aLeRole('super_admin', 'admin_etablissement') ?? false;
    }

    public function rules(): array
    {
        return [
            'document' => ['required', 'file', 'mimes:pdf', 'max:20480'], // 20 Mo max
            'source_id' => ['nullable', 'uuid', 'exists:sources_donnees,id'],
            'universite_id' => ['nullable', 'uuid', 'exists:universites,id'],
            'categorie' => ['nullable', 'string', 'max:100'],
        ];
    }
}
