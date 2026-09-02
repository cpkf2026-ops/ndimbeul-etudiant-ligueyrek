<?php

namespace Tests\Feature;

use App\Models\Utilisateur;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Tests de fumée sur le flux d'authentification — première couverture de test livrée
 * avec le projet (voir README, section "Points de vigilance" : ces tests ne remplacent
 * pas une suite complète mais valident que le cœur de l'auth fonctionne réellement,
 * contrairement au reste du code qui n'a été relu que statiquement).
 */
class AuthentificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_un_lyceen_peut_s_inscrire(): void
    {
        $reponse = $this->postJson('/api/v1/auth/register', [
            'nom' => 'Diop',
            'prenom' => 'Aminata',
            'email' => 'test.lyceen@example.sn',
            'mot_de_passe' => 'MotDePasse123',
            'mot_de_passe_confirmation' => 'MotDePasse123',
            'role' => 'lyceen',
            'region' => 'Dakar',
        ]);

        $reponse->assertStatus(201)
            ->assertJsonStructure(['access_token', 'token_type', 'utilisateur' => ['id', 'email', 'role']]);

        $this->assertDatabaseHas('utilisateurs', ['email' => 'test.lyceen@example.sn', 'role' => 'lyceen']);
        $this->assertDatabaseHas('profils_lyceens', [
            'utilisateur_id' => Utilisateur::where('email', 'test.lyceen@example.sn')->first()->id,
        ]);
    }

    public function test_inscription_avec_role_admin_est_refusee(): void
    {
        // Sécurité : un rôle admin ne doit jamais pouvoir être auto-attribué via /register
        // (voir RegisterRequest::rules — 'role' => 'in:lyceen,etudiant' uniquement).
        $reponse = $this->postJson('/api/v1/auth/register', [
            'nom' => 'Faux', 'prenom' => 'Admin',
            'email' => 'faux.admin@example.sn',
            'mot_de_passe' => 'MotDePasse123', 'mot_de_passe_confirmation' => 'MotDePasse123',
            'role' => 'super_admin',
        ]);

        $reponse->assertStatus(422);
        $this->assertDatabaseMissing('utilisateurs', ['email' => 'faux.admin@example.sn']);
    }

    public function test_connexion_avec_bons_identifiants(): void
    {
        $utilisateur = Utilisateur::factory()->create([
            'email' => 'test.connexion@example.sn',
            'mot_de_passe' => bcrypt('MotDePasse123'),
            'role' => 'etudiant',
        ]);

        $reponse = $this->postJson('/api/v1/auth/login', [
            'email' => 'test.connexion@example.sn',
            'mot_de_passe' => 'MotDePasse123',
        ]);

        $reponse->assertStatus(200)->assertJsonStructure(['access_token', 'utilisateur']);
    }

    public function test_connexion_avec_mauvais_mot_de_passe_est_refusee(): void
    {
        Utilisateur::factory()->create([
            'email' => 'test.connexion2@example.sn',
            'mot_de_passe' => bcrypt('BonMotDePasse'),
        ]);

        $reponse = $this->postJson('/api/v1/auth/login', [
            'email' => 'test.connexion2@example.sn',
            'mot_de_passe' => 'MauvaisMotDePasse',
        ]);

        $reponse->assertStatus(401);
    }

    public function test_un_compte_suspendu_ne_peut_pas_se_connecter(): void
    {
        Utilisateur::factory()->create([
            'email' => 'suspendu@example.sn',
            'mot_de_passe' => bcrypt('MotDePasse123'),
            'statut' => 'suspendu',
        ]);

        $reponse = $this->postJson('/api/v1/auth/login', [
            'email' => 'suspendu@example.sn',
            'mot_de_passe' => 'MotDePasse123',
        ]);

        $reponse->assertStatus(403);
    }

    public function test_un_utilisateur_authentifie_peut_consulter_son_profil(): void
    {
        $utilisateur = Utilisateur::factory()->create(['role' => 'etudiant']);

        $reponse = $this->actingAs($utilisateur, 'sanctum')->getJson('/api/v1/profile/me');

        $reponse->assertStatus(200)->assertJsonPath('utilisateur.id', $utilisateur->id);
    }

    public function test_route_protegee_refuse_l_acces_sans_token(): void
    {
        $this->getJson('/api/v1/profile/me')->assertStatus(401);
    }
}
