<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Table consommee par Django en managed=False.
    public function up(): void
    {
        Schema::create('conversations_ia', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id');
            $table->json('messages')->nullable(); // [{role, contenu, sources, date}]
            $table->timestamps();
            $table->timestamp('date_derniere_activite')->nullable();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('conversations_ia');
    }
};
