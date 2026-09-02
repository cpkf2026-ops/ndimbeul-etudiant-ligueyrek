<?php

namespace App\Policies;

use App\Models\Formation;
use App\Models\Utilisateur;

class FormationPolicy
{
    public function viewAny(?Utilisateur $utilisateur): bool
    {
        return true;
    }

    public function view(?Utilisateur $utilisateur, Formation $formation): bool
    {
        return true;
    }

    public function create(Utilisateur $utilisateur, ?string $universiteId = null): bool
    {
        if ($utilisateur->estSuperAdmin()) {
            return true;
        }

        return $utilisateur->estAdminEtablissement()
            && $universiteId !== null
            && $utilisateur->profilAdmin?->peutGererUniversite($universiteId);
    }

    public function update(Utilisateur $utilisateur, Formation $formation): bool
    {
        if ($utilisateur->estSuperAdmin()) {
            return true;
        }

        return $utilisateur->estAdminEtablissement()
            && $utilisateur->profilAdmin?->peutGererUniversite($formation->universite_id);
    }

    public function delete(Utilisateur $utilisateur, Formation $formation): bool
    {
        return $this->update($utilisateur, $formation);
    }
}
