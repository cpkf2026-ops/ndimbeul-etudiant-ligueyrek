<?php

namespace App\Policies;

use App\Models\Utilisateur;

class UtilisateurPolicy
{
    public function viewAny(Utilisateur $utilisateur): bool
    {
        return $utilisateur->estSuperAdmin();
    }

    public function view(Utilisateur $utilisateur, Utilisateur $cible): bool
    {
        return $utilisateur->estSuperAdmin() || $utilisateur->id === $cible->id;
    }

    public function update(Utilisateur $utilisateur, Utilisateur $cible): bool
    {
        return $utilisateur->estSuperAdmin() || $utilisateur->id === $cible->id;
    }

    public function manageRole(Utilisateur $utilisateur, Utilisateur $cible): bool
    {
        // Un super_admin ne peut pas se rétrograder lui-même par erreur via cette route.
        return $utilisateur->estSuperAdmin() && $utilisateur->id !== $cible->id;
    }

    public function suspend(Utilisateur $utilisateur, Utilisateur $cible): bool
    {
        return $utilisateur->estSuperAdmin() && $utilisateur->id !== $cible->id;
    }

    public function delete(Utilisateur $utilisateur, Utilisateur $cible): bool
    {
        return $utilisateur->estSuperAdmin() && $utilisateur->id !== $cible->id;
    }
}
