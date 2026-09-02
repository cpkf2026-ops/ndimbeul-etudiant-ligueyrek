<?php

namespace App\Policies;

use App\Models\Universite;
use App\Models\Utilisateur;

class UniversitePolicy
{
    public function viewAny(?Utilisateur $utilisateur): bool
    {
        return true; // catalogue public (CDC §2.2)
    }

    public function view(?Utilisateur $utilisateur, Universite $universite): bool
    {
        return true;
    }

    public function create(Utilisateur $utilisateur): bool
    {
        return $utilisateur->estSuperAdmin();
    }

    public function update(Utilisateur $utilisateur, Universite $universite): bool
    {
        if ($utilisateur->estSuperAdmin()) {
            return true;
        }

        return $utilisateur->estAdminEtablissement()
            && $utilisateur->profilAdmin?->peutGererUniversite($universite->id);
    }

    public function delete(Utilisateur $utilisateur, Universite $universite): bool
    {
        return $utilisateur->estSuperAdmin();
    }
}
