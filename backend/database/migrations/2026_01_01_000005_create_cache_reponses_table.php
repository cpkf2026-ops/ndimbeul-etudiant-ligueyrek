<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Table gérée côté Django (managed=False) mais créée par Laravel,
    // conformément au principe "les migrations Laravel créent toutes les tables".
    public function up(): void
    {
        Schema::create('cache_reponses', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('question_hash')->unique();
            $table->json('reponse_json');
            $table->json('sources_utilisees')->nullable();
            $table->timestamp('date_expiration');
            $table->unsignedInteger('nb_utilisations')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cache_reponses');
    }
};
