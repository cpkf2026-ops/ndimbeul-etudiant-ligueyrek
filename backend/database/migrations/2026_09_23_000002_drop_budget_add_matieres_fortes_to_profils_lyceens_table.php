<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('profils_lyceens', function (Blueprint $table) {
            $table->dropColumn('budget_max_annuel');
            // Matières fortes (Tâche 4) : utilisées pour classer les recommandations aux
            // côtés des intérêts/débouchés, après le filtrage éliminatoire par série de bac.
            $table->json('matieres_fortes')->nullable()->after('passions');
        });
    }

    public function down(): void
    {
        Schema::table('profils_lyceens', function (Blueprint $table) {
            $table->decimal('budget_max_annuel', 10, 2)->nullable();
            $table->dropColumn('matieres_fortes');
        });
    }
};
