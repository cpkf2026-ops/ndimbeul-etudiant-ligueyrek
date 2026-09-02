<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('offres_favorites', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id');
            $table->uuid('offre_id');
            $table->timestamp('date_sauvegarde')->useCurrent();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
            $table->foreign('offre_id')->references('id')->on('offres_emploi')->cascadeOnDelete();
            $table->unique(['utilisateur_id', 'offre_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('offres_favorites');
    }
};
