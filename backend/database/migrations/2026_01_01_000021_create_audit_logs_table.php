<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id')->nullable();
            $table->enum('action', ['create', 'update', 'delete', 'login', 'logout', 'role_change']);
            $table->string('entite_modifiee')->nullable();
            $table->string('entite_id')->nullable();
            $table->json('donnees_avant')->nullable();
            $table->json('donnees_apres')->nullable();
            $table->string('ip_source', 45)->nullable();
            $table->timestamp('date_action')->useCurrent();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->nullOnDelete();
            $table->index(['entite_modifiee', 'entite_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
