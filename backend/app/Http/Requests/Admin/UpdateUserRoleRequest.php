<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UpdateUserRoleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('manageRole', $this->route('utilisateur')) ?? false;
    }

    public function rules(): array
    {
        return [
            'role' => ['required', 'in:lyceen,etudiant,diplome,admin_etablissement,super_admin'],
        ];
    }
}
