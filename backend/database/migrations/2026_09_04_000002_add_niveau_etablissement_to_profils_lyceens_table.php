<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('profils_lyceens', function (Blueprint $table) {
            $table->enum('niveau', ['seconde', 'premiere', 'terminale'])->nullable()->after('serie_bac');
            $table->string('etablissement')->nullable()->after('niveau');
        });
    }

    public function down(): void
    {
        Schema::table('profils_lyceens', function (Blueprint $table) {
            $table->dropColumn(['niveau', 'etablissement']);
        });
    }
};
