<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profils_admins', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('utilisateur_id')->unique();
            // admin_etablissement -> rattache a une universite. super_admin -> null (acces global).
            $table->uuid('universite_id')->nullable();
            $table->enum('niveau_acces', ['admin_etablissement', 'super_admin']);
            $table->json('permissions')->nullable();
            $table->string('organisation')->nullable();
            $table->string('contact_pro')->nullable();
            $table->date('date_prise_fonction')->nullable();
            $table->timestamps();

            $table->foreign('utilisateur_id')->references('id')->on('utilisateurs')->cascadeOnDelete();
            $table->foreign('universite_id')->references('id')->on('universites')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profils_admins');
    }
};
