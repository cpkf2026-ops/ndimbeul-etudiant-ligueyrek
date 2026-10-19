<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Veille IA via Tavily (modules 2 et 3 du service superapp_ia) :
 * - `hash_dedoublonnage` : SHA-256 de l'URL normalisée + du titre normalisé. L'index
 *   unique empêche d'enregistrer deux fois la même offre/actualité, même si deux
 *   passages de la veille tournent en même temps. NULL autorisé pour les lignes
 *   antérieures (MySQL accepte plusieurs NULL dans un index unique) ;
 * - offres : `resume` (2 lignes rédigées par le LLM) et `date_collecte`.
 * Ajouts uniquement : aucune donnée existante n'est modifiée ni supprimée.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('offres_emploi', function (Blueprint $table) {
            $table->char('hash_dedoublonnage', 64)->nullable()->unique()->after('id');
            $table->text('resume')->nullable()->after('description');
            $table->timestamp('date_collecte')->nullable()->after('date_indexation');
        });

        Schema::table('actualites', function (Blueprint $table) {
            $table->char('hash_dedoublonnage', 64)->nullable()->unique()->after('id');
        });
    }

    public function down(): void
    {
        Schema::table('offres_emploi', function (Blueprint $table) {
            $table->dropUnique(['hash_dedoublonnage']);
            $table->dropColumn(['hash_dedoublonnage', 'resume', 'date_collecte']);
        });

        Schema::table('actualites', function (Blueprint $table) {
            $table->dropUnique(['hash_dedoublonnage']);
            $table->dropColumn('hash_dedoublonnage');
        });
    }
};
