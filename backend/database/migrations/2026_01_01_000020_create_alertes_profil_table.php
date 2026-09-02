<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Ajoutee pour couvrir le CDC §8.3 / Analyse des besoins §2.6, UC15 :
    // notification de l'etudiant quand une nouvelle offre correspond a son profil.
    public function up(): void
    {
        Schema::create('alertes_profil', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id');
            $table->json('criteres'); // ex: {domaine, region, type, niveau}
            $table->boolean('actif')->default(true);
            $table->timestamp('derniere_notification_le')->nullable();
            $table->timestamps();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
            $table->index(['utilisateur_id', 'actif']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('alertes_profil');
    }
};
