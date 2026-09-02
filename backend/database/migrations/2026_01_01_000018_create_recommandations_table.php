<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Table consommee par Django en managed=False.
    public function up(): void
    {
        Schema::create('recommandations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id');
            $table->uuid('formation_id');
            $table->decimal('score_correspondance', 5, 2);
            $table->text('explication_llm')->nullable();
            $table->json('sources_infos')->nullable();
            $table->timestamp('date_generation')->useCurrent();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
            $table->foreign('formation_id')->references('id')->on('formations')->cascadeOnDelete();
            $table->index(['utilisateur_id', 'date_generation']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recommandations');
    }
};
