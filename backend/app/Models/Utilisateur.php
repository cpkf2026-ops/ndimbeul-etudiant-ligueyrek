<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Auth\Passwords\CanResetPassword;
use Illuminate\Contracts\Auth\CanResetPassword as CanResetPasswordContract;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Utilisateur extends Authenticatable implements CanResetPasswordContract
{
    use CanResetPassword, HasApiTokens, HasFactory, HasUuid, Notifiable, SoftDeletes;

    protected $table = 'utilisateurs';

    public const ROLE_LYCEEN = 'lyceen';
    public const ROLE_ETUDIANT = 'etudiant';
    public const ROLE_DIPLOME = 'diplome';
    public const ROLE_ADMIN_ETABLISSEMENT = 'admin_etablissement';
    public const ROLE_SUPER_ADMIN = 'super_admin';

    protected $fillable = [
        'nom', 'prenom', 'email', 'mot_de_passe', 'role', 'region', 'statut', 'profil_complete',
    ];

    protected $hidden = [
        'mot_de_passe', 'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verifie_le' => 'datetime',
            'date_derniere_connexion' => 'datetime',
            'profil_complete' => 'boolean',
        ];
    }

    /**
     * Sanctum/Auth s'attend par défaut à une colonne "password".
     * Le CDC impose le nommage français "mot_de_passe" : on adapte le point d'entrée.
     */
    public function getAuthPassword(): string
    {
        return $this->mot_de_passe;
    }

    // --- Relations ---

    public function profilLyceen(): HasOne
    {
        return $this->hasOne(ProfilLyceen::class, 'utilisateur_id');
    }

    public function profilEtudiant(): HasOne
    {
        return $this->hasOne(ProfilEtudiant::class, 'utilisateur_id');
    }

    public function profilAdmin(): HasOne
    {
        return $this->hasOne(ProfilAdmin::class, 'utilisateur_id');
    }

    public function profilDiplome(): HasOne
    {
        return $this->hasOne(ProfilDiplome::class, 'utilisateur_id');
    }

    public function formationsFavorites(): HasMany
    {
        return $this->hasMany(FormationFavorite::class, 'utilisateur_id');
    }

    public function offresFavorites(): HasMany
    {
        return $this->hasMany(OffreFavorite::class, 'utilisateur_id');
    }

    public function universitesSuivies(): HasMany
    {
        return $this->hasMany(UniversiteSuivie::class, 'utilisateur_id');
    }

    public function conversationsIa(): HasMany
    {
        return $this->hasMany(ConversationIa::class, 'utilisateur_id');
    }

    public function alertesProfil(): HasMany
    {
        return $this->hasMany(AlerteProfil::class, 'utilisateur_id');
    }

    public function auditLogs(): HasMany
    {
        return $this->hasMany(AuditLog::class, 'utilisateur_id');
    }

    public function sourcesGerees(): HasMany
    {
        return $this->hasMany(SourceDonnee::class, 'admin_id');
    }

    // --- Helpers de rôle (RBAC) ---

    public function aLeRole(string ...$roles): bool
    {
        return in_array($this->role, $roles, true);
    }

    public function estLyceen(): bool
    {
        return $this->role === self::ROLE_LYCEEN;
    }

    public function estEtudiant(): bool
    {
        return $this->role === self::ROLE_ETUDIANT;
    }

    public function estDiplome(): bool
    {
        return $this->role === self::ROLE_DIPLOME;
    }

    public function estAdminEtablissement(): bool
    {
        return $this->role === self::ROLE_ADMIN_ETABLISSEMENT;
    }

    public function estSuperAdmin(): bool
    {
        return $this->role === self::ROLE_SUPER_ADMIN;
    }

    public function estActif(): bool
    {
        return $this->statut === 'actif';
    }

    /**
     * Surcharge la notification par défaut pour pointer vers le deep-link Flutter
     * plutôt que vers une route web Blade (CDC §2.1 "réinitialisation par lien email sécurisé").
     */
    public function sendPasswordResetNotification($token): void
    {
        $frontendUrl = rtrim((string) config('services.frontend.reset_password_url'), '/');
        $lien = sprintf('%s?token=%s&email=%s', $frontendUrl, $token, urlencode($this->email));

        $this->notify(new \App\Notifications\ReinitialisationMotDePasse($lien));
    }
}
