<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Sources de confiance du service IA (paramètre `include_domains` de Tavily, voir
 * superapp_ia/services/sources.py). Modifiables depuis le back-office : une
 * catégorie sans aucune ligne retombe sur les valeurs par défaut de sources.py.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sources_confiance', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('domaine', 120);   // ex : 'campusen.sn' (sans http ni www)
            $table->string('nom')->nullable();
            $table->enum('categorie', ['orientation', 'emploi', 'actualites']);
            $table->boolean('actif')->default(true);
            $table->timestamps();

            $table->unique(['domaine', 'categorie']);
            $table->index(['categorie', 'actif']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sources_confiance');
    }
};
