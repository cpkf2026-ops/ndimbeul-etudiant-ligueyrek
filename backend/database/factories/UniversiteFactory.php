<?php

namespace Database\Factories;

use App\Models\Universite;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Universite>
 */
class UniversiteFactory extends Factory
{
    protected $model = Universite::class;

    public function definition(): array
    {
        return [
            'nom' => fake()->company().' University',
            'code_unique' => strtoupper(fake()->unique()->lexify('????')),
            'region' => fake()->randomElement(['Dakar', 'Thiès', 'Saint-Louis', 'Diourbel', 'Ziguinchor']),
            'commune' => fake()->city(),
            'type' => fake()->randomElement(['public', 'prive']),
            'site_web_officiel' => fake()->url(),
            'description' => fake()->paragraph(),
            'statut_actif' => true,
        ];
    }
}
