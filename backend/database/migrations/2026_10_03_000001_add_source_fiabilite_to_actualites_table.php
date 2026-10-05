<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Traçabilité des actualités trouvées par la veille IA : nom du média / site
 * officiel d'origine et niveau de fiabilité de la source ('officiel' | 'presse'),
 * renseignés par le pipeline Django (superapp_ia/veille/fiabilite.py).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('actualites', function (Blueprint $table) {
            $table->string('source_nom', 120)->nullable()->after('source_url');
            $table->string('fiabilite', 20)->nullable()->after('source_nom');
        });
    }

    public function down(): void
    {
        Schema::table('actualites', function (Blueprint $table) {
            $table->dropColumn(['source_nom', 'fiabilite']);
        });
    }
};
