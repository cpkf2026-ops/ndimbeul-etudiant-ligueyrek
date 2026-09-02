<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profils_etudiants', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id')->unique();
            $table->string('universite_actuelle')->nullable();
            $table->string('formation_actuelle')->nullable();
            $table->enum('niveau_actuel', ['L1', 'L2', 'L3', 'M1', 'M2', 'Doctorat'])->nullable();
            $table->json('domaines_interets')->nullable();
            $table->boolean('recherche_stage')->default(false);
            $table->boolean('recherche_emploi')->default(false);
            $table->timestamps();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profils_etudiants');
    }
};
