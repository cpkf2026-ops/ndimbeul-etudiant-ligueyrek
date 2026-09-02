<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('universites', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('nom');
            $table->string('code_unique')->unique();
            $table->string('region')->nullable();
            $table->string('commune')->nullable();
            $table->enum('type', ['public', 'prive']);
            $table->string('site_web_officiel')->nullable();
            $table->text('description')->nullable();
            $table->string('email_contact')->nullable();
            $table->string('telephone_contact')->nullable();
            $table->boolean('statut_actif')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index(['region', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('universites');
    }
};
