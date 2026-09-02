<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('utilisateurs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('nom');
            $table->string('prenom');
            $table->string('email')->unique();
            $table->string('mot_de_passe');
            $table->enum('role', ['lyceen', 'etudiant', 'admin_etablissement', 'super_admin'])
                ->default('lyceen');
            $table->string('region')->nullable();
            $table->enum('statut', ['actif', 'suspendu'])->default('actif');
            $table->timestamp('email_verifie_le')->nullable();
            $table->timestamp('date_derniere_connexion')->nullable();
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();

            $table->index('role');
            $table->index('statut');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('utilisateurs');
    }
};
