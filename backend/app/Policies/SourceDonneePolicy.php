<?php

namespace App\Policies;

use App\Models\SourceDonnee;
use App\Models\Utilisateur;

class SourceDonneePolicy
{
    public function viewAny(Utilisateur $utilisateur): bool
    {
        return $utilisateur->aLeRole('super_admin', 'admin_etablissement');
    }

    public function view(Utilisateur $utilisateur, SourceDonnee $source): bool
    {
        if ($utilisateur->estSuperAdmin()) {
            return true;
        }

        return $utilisateur->estAdminEtablissement()
            && $source->universite_id !== null
            && $utilisateur->profilAdmin?->peutGererUniversite($source->universite_id);
    }

    public function create(Utilisateur $utilisateur): bool
    {
        return $utilisateur->aLeRole('super_admin', 'admin_etablissement');
    }

    public function update(Utilisateur $utilisateur, SourceDonnee $source): bool
    {
        return $this->view($utilisateur, $source);
    }

    public function delete(Utilisateur $utilisateur, SourceDonnee $source): bool
    {
        return $this->view($utilisateur, $source);
    }
}
