<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('universites', function (Blueprint $table) {
            // Traçabilité de la donnée (Tâche 1 du cahier des charges) : d'où vient
            // chaque fiche établissement et quand elle a été vérifiée pour la dernière
            // fois — indispensable pour distinguer une donnée vérifiée d'une donnée
            // obsolète, sans jamais en inventer le contenu.
            $table->string('source')->nullable()->after('site_web_officiel');
            $table->date('date_verification')->nullable()->after('source');
        });
    }

    public function down(): void
    {
        Schema::table('universites', function (Blueprint $table) {
            $table->dropColumn(['source', 'date_verification']);
        });
    }
};
