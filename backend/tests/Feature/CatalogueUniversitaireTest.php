<?php

namespace Tests\Feature;

use App\Models\Formation;
use App\Models\Universite;
use App\Models\Utilisateur;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Couvre en particulier le bug d'ordre de routes corrigé lors de la revue de conformité
 * (routes statiques /compare, /history, /favorites déclarées avant les routes {id}) —
 * ces tests auraient échoué avec l'ancien routes/api.php.
 */
class CatalogueUniversitaireTest extends TestCase
{
    use RefreshDatabase;

    public function test_le_catalogue_est_accessible_sans_authentification(): void
    {
        Universite::factory()->count(3)->create(['statut_actif' => true]);

        $this->getJson('/api/v1/universities')->assertStatus(200)->assertJsonCount(3, 'data');
    }

    public function test_la_route_compare_n_est_pas_interceptee_par_la_route_id(): void
    {
        // Régression : /universities/compare doit atteindre UniversityController::compare(),
        // pas être interprétée comme /universities/{universite} avec id="compare".
        $u1 = Universite::factory()->create();
        $u2 = Universite::factory()->create();

        $reponse = $this->getJson("/api/v1/universities/compare?ids={$u1->id},{$u2->id}");

        $reponse->assertStatus(200)->assertJsonCount(2, 'data');
    }

    public function test_la_route_history_n_est_pas_interceptee_par_la_route_id(): void
    {
        $utilisateur = Utilisateur::factory()->create();

        $reponse = $this->actingAs($utilisateur, 'sanctum')->getJson('/api/v1/universities/history');

        $reponse->assertStatus(200); // et non 404 comme avec l'ancien ordre de routes
    }

    public function test_la_route_favorites_formations_n_est_pas_interceptee_par_la_route_id(): void
    {
        $utilisateur = Utilisateur::factory()->create();

        $reponse = $this->actingAs($utilisateur, 'sanctum')->getJson('/api/v1/formations/favorites');

        $reponse->assertStatus(200);
    }

    public function test_un_etudiant_peut_ajouter_et_lister_une_formation_favorite(): void
    {
        $utilisateur = Utilisateur::factory()->etudiant()->create();
        $universite = Universite::factory()->create();
        $formation = Formation::factory()->for($universite, 'universite')->create();

        $this->actingAs($utilisateur, 'sanctum')
            ->postJson("/api/v1/formations/{$formation->id}/favorite")
            ->assertStatus(201);

        $reponse = $this->actingAs($utilisateur, 'sanctum')->getJson('/api/v1/formations/favorites');

        $reponse->assertStatus(200)->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $formation->id);
    }

    public function test_la_fiche_universite_inclut_formations_bourses_logements_frais(): void
    {
        $universite = Universite::factory()->create();
        Formation::factory()->for($universite, 'universite')->create();

        $reponse = $this->getJson("/api/v1/universities/{$universite->id}");

        $reponse->assertStatus(200)->assertJsonStructure([
            'data' => ['id', 'nom', 'formations', 'bourses', 'logements', 'frais_scolarite'],
        ]);
    }
}
