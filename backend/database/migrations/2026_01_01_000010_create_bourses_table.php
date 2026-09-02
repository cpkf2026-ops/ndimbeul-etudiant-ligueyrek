<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Ajoutee au perimetre pour respecter le CDC (§5.3, §7.3, §8.2) :
    // les bourses doivent etre une donnee structuree et filtrable, pas un bloc de texte libre.
    public function up(): void
    {
        Schema::create('bourses', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('universite_id')->nullable(); // null = bourse nationale, non liee a un etablissement
            $table->string('nom');
            $table->string('organisme')->nullable();
            $table->decimal('montant', 12, 2)->nullable();
            $table->string('devise', 10)->default('XOF');
            $table->text('conditions')->nullable();
            $table->text('demarches')->nullable();
            $table->date('date_limite')->nullable();
            $table->string('lien')->nullable();
            $table->string('source')->nullable();
            $table->timestamp('date_maj')->nullable();
            $table->timestamps();

            $table->foreign('universite_id')->references('id')->on('universites')->cascadeOnDelete();
            $table->index('date_limite');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bourses');
    }
};
