<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // `role` doit accepter le statut "diplome" et devenir optionnel : il n'est
        // plus fixé à l'inscription, seulement quand l'utilisateur complète son
        // profil (voir ProfileController::complete()). MySQL n'autorise pas de
        // MODIFY COLUMN portant à la fois sur l'ENUM et la nullabilité via le
        // blueprint Laravel courant ici (pas de doctrine/dbal) : on passe par du
        // SQL brut, cohérent avec le `enum()` d'origine de la migration
        // 2026_01_01_000001_create_utilisateurs_table.
        DB::statement(
            "ALTER TABLE utilisateurs MODIFY role ENUM('lyceen', 'etudiant', 'diplome', 'admin_etablissement', 'super_admin') NULL DEFAULT NULL"
        );

        Schema::table('utilisateurs', function ($table) {
            $table->boolean('profil_complete')->default(false)->after('role');
        });
    }

    public function down(): void
    {
        Schema::table('utilisateurs', function ($table) {
            $table->dropColumn('profil_complete');
        });

        DB::statement(
            "ALTER TABLE utilisateurs MODIFY role ENUM('lyceen', 'etudiant', 'admin_etablissement', 'super_admin') NOT NULL DEFAULT 'lyceen'"
        );
    }
};
