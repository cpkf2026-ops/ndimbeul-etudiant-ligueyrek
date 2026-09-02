<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('actualites', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('titre');
            $table->text('contenu');
            $table->uuid('auteur_id')->nullable();
            $table->enum('categorie', ['bourse', 'concours', 'evenement', 'formation', 'general']);
            $table->string('source_url')->nullable();
            $table->string('image_url')->nullable();
            $table->date('date_publication')->nullable();
            $table->json('cible_roles')->nullable();
            $table->enum('statut', ['brouillon', 'publie', 'archive'])->default('brouillon');
            $table->timestamps();

            $table->foreign('auteur_id')->references('id')->on('utilisateurs')->nullOnDelete();
            $table->index(['categorie', 'statut']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('actualites');
    }
};
