<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('formations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('universite_id');
            $table->string('intitule');
            $table->string('domaine')->nullable();
            $table->enum('niveau', ['bts', 'licence', 'master', 'doctorat']);
            $table->unsignedTinyInteger('duree_annees')->nullable();
            $table->json('series_acceptees')->nullable();
            $table->decimal('moyenne_minimale', 4, 2)->nullable();
            $table->unsignedInteger('capacite')->nullable();
            $table->text('prerequis')->nullable();
            $table->text('debouches')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('universite_id')->references('id')->on('universites')->cascadeOnDelete();
            $table->index(['domaine', 'niveau']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('formations');
    }
};
