<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profils_lyceens', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id')->unique();
            $table->string('serie_bac', 10)->nullable();
            $table->decimal('moyenne_generale', 4, 2)->nullable();
            $table->json('passions')->nullable();
            $table->json('metiers_envisages')->nullable();
            $table->decimal('budget_max_annuel', 10, 2)->nullable();
            $table->boolean('mobilite')->default(false);
            $table->enum('pref_public_prive', ['public', 'prive', 'indifferent'])->default('indifferent');
            $table->string('region_cible')->nullable();
            $table->unsignedSmallInteger('annee_terminale')->nullable();
            $table->timestamps();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profils_lyceens');
    }
};
