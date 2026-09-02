<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Table consommee par Django en managed=False (indexation FAISS).
    // Creee ici pour respecter le principe : Laravel possede TOUTES les migrations.
    public function up(): void
    {
        Schema::create('documents_rag', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('source_id');
            $table->string('titre')->nullable();
            $table->longText('contenu_texte');
            $table->unsignedInteger('nb_chunks')->default(0);
            $table->timestamp('date_indexation')->nullable();
            $table->string('version_embedding')->nullable();
            $table->string('vecteur_faiss_id')->nullable();
            $table->timestamps();

            $table->foreign('source_id')->references('id')->on('sources_donnees')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('documents_rag');
    }
};
