<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Retablie car requise par le CDC §7.4 / Analyse des besoins §2.8 :
    // historique des universites suggerees / consultees / comparees.
    public function up(): void
    {
        Schema::create('universites_suivies', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id');
            $table->uuid('universite_id');
            $table->enum('statut', ['suggeree', 'consultee', 'comparee']);
            $table->decimal('score_matching', 5, 2)->nullable();
            $table->timestamp('date_ajout')->useCurrent();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
            $table->foreign('universite_id')->references('id')->on('universites')->cascadeOnDelete();
            $table->index(['utilisateur_id', 'statut']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('universites_suivies');
    }
};
