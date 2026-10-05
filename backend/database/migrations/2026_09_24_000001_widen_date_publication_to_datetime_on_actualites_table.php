<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * `date_publication` était une simple DATE (pas d'heure) : la veille IA peut
     * désormais extraire l'heure réelle de publication depuis les métadonnées de
     * l'article source (voir veille/recherche_web.py::extraire_metadonnees_article côté
     * Django) — on élargit la colonne pour la stocker telle quelle plutôt que de la
     * tronquer. Les lignes existantes gardent leur date, avec une heure à 00:00:00.
     */
    public function up(): void
    {
        DB::statement('ALTER TABLE actualites MODIFY date_publication DATETIME NULL');
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE actualites MODIFY date_publication DATE NULL');
    }
};
