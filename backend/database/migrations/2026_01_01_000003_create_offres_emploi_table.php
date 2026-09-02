<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('offres_emploi', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('intitule');
            $table->string('entreprise');
            $table->enum('type', ['emploi', 'stage', 'alternance', 'formation', 'bourse']);
            $table->string('domaine')->nullable();
            $table->string('niveau_requis')->nullable();
            $table->string('region')->nullable();
            $table->text('description')->nullable();
            $table->string('source_url', 500);
            $table->string('source')->nullable();
            $table->date('date_publication')->nullable();
            $table->date('date_limite')->nullable();
            $table->enum('statut', ['active', 'expiree'])->default('active');
            $table->timestamp('date_indexation')->useCurrent();
            $table->timestamps();

            $table->unique(['source_url', 'intitule']);
            $table->index(['statut', 'domaine']);
            $table->index(['region', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('offres_emploi');
    }
};
