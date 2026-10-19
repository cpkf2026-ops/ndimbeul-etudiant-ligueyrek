<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Fiche enrichie des établissements (surtout ceux sans site officiel) : informations publiques
 * collectées par le service IA (annuaire, recherche web) et affichées sur leur page dans l'app.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('universites', function (Blueprint $table) {
            $table->string('adresse')->nullable()->after('commune');
            $table->json('domaines')->nullable()->after('description');
            $table->json('diplomes')->nullable()->after('domaines');
            $table->text('admission')->nullable()->after('diplomes');
            $table->json('niveau_requis')->nullable()->after('admission');
            $table->json('pieces_a_fournir')->nullable()->after('niveau_requis');
            $table->string('source_infos')->nullable()->after('pieces_a_fournir');
        });
    }

    public function down(): void
    {
        Schema::table('universites', function (Blueprint $table) {
            $table->dropColumn(['adresse', 'domaines', 'diplomes', 'admission', 'niveau_requis',
                'pieces_a_fournir', 'source_infos']);
        });
    }
};
