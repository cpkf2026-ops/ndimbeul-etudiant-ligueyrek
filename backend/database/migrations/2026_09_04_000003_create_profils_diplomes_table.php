<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profils_diplomes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id')->unique();
            $table->string('dernier_diplome');
            $table->string('domaine')->nullable();
            $table->enum('situation_actuelle', ['en_poste', 'recherche_emploi', 'stage']);
            $table->string('entreprise')->nullable();
            $table->timestamps();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profils_diplomes');
    }
};
