<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Compteur de crédits Tavily (service IA superapp_ia, voir services/credits.py) :
 * une ligne par jour, séparée entre la veille automatique (offres + actualités)
 * et les usages interactifs (chatbot, orientation). Le total du mois est comparé
 * à TAVILY_MONTHLY_LIMIT pour basculer la veille en mode réduit.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('credits_tavily', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->date('jour')->unique();
            $table->unsignedInteger('credits_veille')->default(0);
            $table->unsignedInteger('credits_interactif')->default(0);
            $table->unsignedInteger('nb_requetes')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('credits_tavily');
    }
};
