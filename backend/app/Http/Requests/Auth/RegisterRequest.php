<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // inscription publique
    }

    public function rules(): array
    {
        return [
            'nom' => ['required', 'string', 'max:100'],
            'prenom' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:255', 'unique:utilisateurs,email'],
            'mot_de_passe' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()],
            'region' => ['nullable', 'string', 'max:100'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'Un compte existe déjà avec cet email.',
            'mot_de_passe.confirmed' => 'La confirmation du mot de passe ne correspond pas.',
        ];
    }
}
