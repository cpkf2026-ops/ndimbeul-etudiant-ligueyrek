<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Validation de la complétion de profil (POST /profile/complete) : le champ
 * `statut` fixe le futur `role` de l'utilisateur, et détermine quels champs
 * spécifiques deviennent obligatoires — voir ProfileController::complete().
 */
class CompleteProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'statut' => ['required', 'in:lyceen,etudiant,diplome'],

            // Lycéen
            'serie_bac' => ['required_if:statut,lyceen', 'nullable', 'string', 'max:10'],
            'niveau' => ['required_if:statut,lyceen', 'nullable', 'in:seconde,premiere,terminale'],
            'etablissement' => ['required_if:statut,lyceen', 'nullable', 'string', 'max:255'],
            'annee_terminale' => ['nullable', 'integer', 'min:2020', 'max:2100'],

            // Étudiant
            'universite_actuelle' => ['required_if:statut,etudiant', 'nullable', 'string', 'max:255'],
            'formation_actuelle' => ['required_if:statut,etudiant', 'nullable', 'string', 'max:255'],
            'niveau_actuel' => ['required_if:statut,etudiant', 'nullable', 'in:L1,L2,L3,M1,M2,Doctorat'],

            // Diplômé / en poste / en stage
            'dernier_diplome' => ['required_if:statut,diplome', 'nullable', 'string', 'max:255'],
            'domaine' => ['nullable', 'string', 'max:255'],
            'situation_actuelle' => ['required_if:statut,diplome', 'nullable', 'in:en_poste,recherche_emploi,stage'],
            'entreprise' => ['nullable', 'string', 'max:255'],
        ];
    }

    public function messages(): array
    {
        return [
            'statut.required' => 'Merci de choisir votre statut.',
            '*.required_if' => 'Ce champ est obligatoire pour ce statut.',
        ];
    }
}
