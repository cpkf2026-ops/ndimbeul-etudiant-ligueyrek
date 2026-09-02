<?php

namespace Database\Factories;

use App\Models\Utilisateur;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

/**
 * @extends Factory<Utilisateur>
 */
class UtilisateurFactory extends Factory
{
    protected $model = Utilisateur::class;

    public function definition(): array
    {
        return [
            'nom' => fake()->lastName(),
            'prenom' => fake()->firstName(),
            'email' => fake()->unique()->safeEmail(),
            'mot_de_passe' => Hash::make('password'),
            'role' => fake()->randomElement(['lyceen', 'etudiant']),
            'region' => fake()->randomElement(['Dakar', 'Thiès', 'Saint-Louis', 'Diourbel', 'Ziguinchor']),
            'statut' => 'actif',
        ];
    }

    public function lyceen(): static
    {
        return $this->state(fn () => ['role' => 'lyceen']);
    }

    public function etudiant(): static
    {
        return $this->state(fn () => ['role' => 'etudiant']);
    }

    public function superAdmin(): static
    {
        return $this->state(fn () => ['role' => 'super_admin']);
    }

    public function suspendu(): static
    {
        return $this->state(fn () => ['statut' => 'suspendu']);
    }
}
