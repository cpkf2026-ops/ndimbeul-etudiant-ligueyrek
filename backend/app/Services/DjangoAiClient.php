<?php

namespace App\Services;

use Illuminate\Http\Client\PendingRequest;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;
use RuntimeException;

/**
 * Client HTTP interne Laravel -> Django (§9 CDC : "Communication API REST Flutter ↔ Laravel
 * (Sanctum JWT) ↔ Django IA (X-Internal-Key)"). Django n'est JAMAIS exposé directement à Flutter :
 * tous les appels transitent par ce service, qui ajoute le header d'authentification inter-services.
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
            ->withHeaders(['X-Internal-Key' => $this->internalKey])
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
            ->withHeaders(['X-Internal-Key' => $this->internalKey])
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
            ->withHeaders(['X-Internal-Key' => $this->internalKey])
            ->timeout($this->timeout)
            ->attach('document', file_get_contents($cheminAbsolu), $nomOriginal)
            ->post('/internal/documents/index', $metadonnees);
    }

    public function qualityMetrics(): Response
    {
        return $this->client()->get('/internal/quality-metrics');
    }
}
