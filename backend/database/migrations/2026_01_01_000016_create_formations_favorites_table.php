<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('formations_favorites', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id');
            $table->uuid('formation_id');
            $table->timestamp('date_sauvegarde')->useCurrent();
            $table->text('notes_perso')->nullable();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
            $table->foreign('formation_id')->references('id')->on('formations')->cascadeOnDelete();
            $table->unique(['utilisateur_id', 'formation_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('formations_favorites');
    }
};
