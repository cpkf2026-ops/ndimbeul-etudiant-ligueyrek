<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProfilAdmin extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'profils_admins';

    protected $fillable = [
        'utilisateur_id', 'universite_id', 'niveau_acces', 'permissions',
        'organisation', 'contact_pro', 'date_prise_fonction',
    ];

    protected function casts(): array
    {
        return [
            'permissions' => 'array',
            'date_prise_fonction' => 'date',
        ];
    }

    public function utilisateur(): BelongsTo
    {
        return $this->belongsTo(Utilisateur::class, 'utilisateur_id');
    }

    public function universite(): BelongsTo
    {
        return $this->belongsTo(Universite::class, 'universite_id');
    }

    public function aPermission(string $permission): bool
    {
        if ($this->niveau_acces === 'super_admin') {
            return true;
        }

        return in_array($permission, $this->permissions ?? [], true);
    }

    /**
     * Un admin_etablissement ne peut agir que sur SON université.
     * Un super_admin a une portée illimitée (universite_id = null).
     */
    public function peutGererUniversite(string $universiteId): bool
    {
        return $this->niveau_acces === 'super_admin'
            || $this->universite_id === $universiteId;
    }
}
