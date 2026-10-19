<?php

namespace App\Services;

use Illuminate\Http\Client\PendingRequest;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;
use RuntimeException;

/**
 * Client HTTP interne Laravel -> Django (§9 CDC : "Communication API REST Flutter ↔ Laravel
 * (Sanctum JWT) ↔ Django IA"). Django n'est JAMAIS exposé directement à Flutter : tous les appels
 * transitent par ce service, qui ajoute l'en-tête d'authentification inter-services X-Service-Token
 * (valeur DJANGO_IA_INTERNAL_KEY, identique à LARAVEL_SHARED_TOKEN côté superapp_ia/.env).
 *
 * Routes du service IA (voir superapp_ia/API_IA.md pour les exemples JSON) :
 *   POST /api/ia/orientation/   GET /api/ia/opportunites/   GET /api/ia/actualites/
 *   POST /api/ia/chat/          POST /api/ia/chat/stream/   GET /api/ia/sante/
 */
class DjangoAiClient
{
    private string $baseUrl;
    private string $internalKey;
    private int $timeout;

    public function __construct()
    {
        $this->baseUrl = rtrim((string) config('services.django_ia.base_url'), '/');
        $this->internalKey = (string) config('services.django_ia.internal_key');
        $this->timeout = (int) config('services.django_ia.timeout', 30);

        if (empty($this->baseUrl) || empty($this->internalKey)) {
            throw new RuntimeException(
                'Configuration Django IA manquante : vérifier DJANGO_IA_BASE_URL et DJANGO_IA_INTERNAL_KEY dans .env'
            );
        }
    }

    private function client(): PendingRequest
    {
        return Http::baseUrl($this->baseUrl)
            ->withHeaders(['X-Service-Token' => $this->internalKey])
            ->timeout($this->timeout)
            ->acceptJson();
    }

    public function chat(array $payload): Response
    {
        return $this->client()->post('/internal/chat', $payload);
    }

    /**
     * Variante streaming SSE : on ouvre la connexion et on relaie le flux
     * brut à Flutter sans attendre la réponse complète (voir AiProxyController).
     */
    public function chatStream(array $payload): \Psr\Http\Message\StreamInterface
    {
        $response = Http::baseUrl($this->baseUrl)
            ->withHeaders(['X-Service-Token' => $this->internalKey])
            ->withOptions(['stream' => true])
            ->timeout($this->timeout)
            ->post('/internal/chat', $payload);

        return $response->toPsrResponse()->getBody();
    }

    public function recommendations(array $payload): Response
    {
        return $this->client()->post('/internal/recommendations', $payload);
    }

    public function searchUniversity(array $payload): Response
    {
        return $this->client()->post('/internal/search-university', $payload);
    }

    /**
     * Transmet le CONTENU réel du fichier (pas seulement son chemin) : Laravel et Django
     * tournent dans des conteneurs distincts (architecture Docker du CDC §9), donc un simple
     * chemin de stockage local n'est pas résoluble côté Django. On envoie le fichier en
     * multipart, ce qui fonctionne quel que soit le déploiement (conteneurs séparés ou
     * volume partagé). $metadonnees contient les champs texte (source_id, universite_id, categorie...).
     */
    public function indexDocument(string $cheminAbsolu, string $nomOriginal, array $metadonnees): Response
    {
        // ->attach() bascule le client en multipart ; les champs simples passés ensuite à
        // post($url, $data) sont automatiquement envoyés comme champs texte du même formulaire.
        return Http::baseUrl($this->baseUrl)
            ->withHeaders(['X-Service-Token' => $this->internalKey])
            ->timeout($this->timeout)
            ->attach('document', file_get_contents($cheminAbsolu), $nomOriginal)
            ->post('/internal/documents/index', $metadonnees);
    }

    public function qualityMetrics(): Response
    {
        return $this->client()->get('/internal/quality-metrics');
    }

    // ------------------------------------------------------------------
    // Service IA « Tavily cherche, Mistral rédige » (modules 1 à 4)
    // ------------------------------------------------------------------

    /** Module 1 : {serie_bac, moyenne, passions[], ville?, utilisateur_id?} -> métiers, formations, universités. */
    public function orientation(array $profil): Response
    {
        return $this->client()->post('/api/ia/orientation/', $profil);
    }

    /** Module 2 : $filtres = ['categorie' => 'stage', 'page' => 1, 'par_page' => 20]. */
    public function opportunites(array $filtres = []): Response
    {
        return $this->client()->get('/api/ia/opportunites/', $filtres);
    }

    /** Module 3 : $filtres = ['page' => 1, 'categorie' => 'bourse']. */
    public function actualites(array $filtres = []): Response
    {
        return $this->client()->get('/api/ia/actualites/', $filtres);
    }

    /** Module 4 (JSON) : {message, utilisateur_id?, conversation_id?, profil?, historique?} -> {reponse, sources, temps_ms}. */
    public function chatJson(array $payload): Response
    {
        return $this->client()->post('/api/ia/chat/', $payload);
    }

    /** État d'Ollama, Redis, base et crédits Tavily restants. */
    public function sante(): Response
    {
        return $this->client()->get('/api/ia/sante/');
    }
}
