<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('logements', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('universite_id');
            $table->string('nom');
            $table->enum('type', ['residence', 'foyer', 'partenaire']);
            $table->unsignedInteger('capacite')->nullable();
            $table->decimal('tarif_mensuel', 10, 2)->nullable();
            $table->string('devise', 10)->default('XOF');
            $table->string('contact')->nullable();
            $table->string('source')->nullable();
            $table->timestamp('date_maj')->nullable();
            $table->timestamps();

            $table->foreign('universite_id')->references('id')->on('universites')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('logements');
    }
};
