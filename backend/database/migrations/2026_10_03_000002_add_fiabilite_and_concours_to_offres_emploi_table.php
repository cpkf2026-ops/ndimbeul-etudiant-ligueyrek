<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Veille IA des offres (superapp_ia/veille) :
 * - `fiabilite` : niveau de la source vérifié par la veille ('officiel' | 'presse' |
 *   'plateforme'), NULL pour les offres indexées avant ces règles ;
 * - type `concours` ajouté (concours de la fonction publique, d'entrée en école).
 * Ajouts uniquement : aucune donnée existante n'est modifiée ni supprimée.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('offres_emploi', function (Blueprint $table) {
            $table->string('fiabilite', 20)->nullable()->after('source');
        });

        DB::statement(
            "ALTER TABLE offres_emploi MODIFY type ENUM('emploi','stage','alternance','formation','bourse','concours') NOT NULL"
        );
    }

    public function down(): void
    {
        // Les offres « concours » repassent en « emploi » avant de retirer la valeur
        // de l'énumération (sinon MySQL refuserait la modification).
        DB::table('offres_emploi')->where('type', 'concours')->update(['type' => 'emploi']);
        DB::statement(
            "ALTER TABLE offres_emploi MODIFY type ENUM('emploi','stage','alternance','formation','bourse') NOT NULL"
        );

        Schema::table('offres_emploi', function (Blueprint $table) {
            $table->dropColumn('fiabilite');
        });
    }
};
