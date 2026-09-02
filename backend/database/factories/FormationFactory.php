<?php

namespace Database\Factories;

use App\Models\Formation;
use App\Models\Universite;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Formation>
 */
class FormationFactory extends Factory
{
    protected $model = Formation::class;

    public function definition(): array
    {
        return [
            'universite_id' => Universite::factory(),
            'intitule' => 'Licence '.fake()->words(2, true),
            'domaine' => fake()->randomElement(['Informatique', 'Gestion', 'Sciences', 'Droit']),
            'niveau' => fake()->randomElement(['bts', 'licence', 'master', 'doctorat']),
            'duree_annees' => fake()->numberBetween(2, 5),
            'series_acceptees' => ['S1', 'S2'],
            'moyenne_minimale' => fake()->randomFloat(2, 8, 15),
            'capacite' => fake()->numberBetween(30, 300),
        ];
    }
}
