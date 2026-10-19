<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Statut public/privé : NULL quand il n'a pas pu être vérifié (source officielle ANAQ-Sup / MESRI
 * ou mention explicite de l'établissement). On n'affiche jamais un statut deviné.
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE universites MODIFY type ENUM('public','prive') NULL DEFAULT NULL");
    }

    public function down(): void
    {
        DB::statement("UPDATE universites SET type='public' WHERE type IS NULL");
        DB::statement("ALTER TABLE universites MODIFY type ENUM('public','prive') NOT NULL");
    }
};
