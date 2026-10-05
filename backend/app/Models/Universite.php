<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Universite extends Model
{
    use HasFactory, HasUuid, SoftDeletes;

    protected $table = 'universites';

    protected $fillable = [
        'nom', 'code_unique', 'region', 'commune', 'type', 'site_web_officiel',
        'source', 'date_verification', 'description', 'image_url', 'email_contact',
        'telephone_contact', 'statut_actif',
    ];

    protected function casts(): array
    {
        return [
            'statut_actif' => 'boolean',
            'date_verification' => 'date',
        ];
    }

    public function formations(): HasMany
    {
        return $this->hasMany(Formation::class, 'universite_id');
    }

    public function bourses(): HasMany
    {
        return $this->hasMany(Bourse::class, 'universite_id');
    }

    public function logements(): HasMany
    {
        return $this->hasMany(Logement::class, 'universite_id');
    }

    public function fraisScolarite(): HasMany
    {
        return $this->hasMany(FraisScolarite::class, 'universite_id');
    }

    public function sourcesDonnees(): HasMany
    {
        return $this->hasMany(SourceDonnee::class, 'universite_id');
    }

    public function admins(): HasMany
    {
        return $this->hasMany(ProfilAdmin::class, 'universite_id');
    }

    public function scopeDansRegion($query, ?string $region)
    {
        return $region ? $query->where('region', $region) : $query;
    }

    public function scopeDeType($query, ?string $type)
    {
        return $type ? $query->where('type', $type) : $query;
    }
}
