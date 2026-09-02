<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('frais_scolarite', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('universite_id');
            $table->uuid('formation_id')->nullable();
            $table->decimal('montant', 12, 2);
            $table->string('devise', 10)->default('XOF');
            $table->json('echeancier')->nullable();
            $table->json('moyens_paiement')->nullable(); // ex: ["especes","orange_money","wave","virement"]
            $table->string('source')->nullable();
            $table->timestamp('date_maj')->nullable();
            $table->timestamps();

            $table->foreign('universite_id')->references('id')->on('universites')->cascadeOnDelete();
            $table->foreign('formation_id')->references('id')->on('formations')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('frais_scolarite');
    }
};
