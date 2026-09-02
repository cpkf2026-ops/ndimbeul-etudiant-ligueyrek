<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sources_donnees', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('universite_id')->nullable();
            $table->uuid('admin_id')->nullable();
            $table->enum('type', ['url', 'pdf', 'api']);
            $table->string('url_ou_chemin', 500);
            $table->string('categorie')->nullable(); // formations, bourses, logement, frais, emploi...
            $table->timestamp('date_dernier_crawl')->nullable();
            $table->enum('statut', ['actif', 'erreur', 'obsolete'])->default('actif');
            $table->text('derniere_erreur')->nullable();
            $table->timestamps();

            $table->foreign('universite_id')->references('id')->on('universites')->cascadeOnDelete();
            $table->foreign('admin_id')->references('id')->on('utilisateurs')->nullOnDelete();
            $table->index('statut');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sources_donnees');
    }
};
