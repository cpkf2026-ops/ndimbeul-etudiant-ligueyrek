"""
Façade de compatibilité vers services/llm_service.py, qui contient désormais
l'implémentation du client Ollama.

Le code existant (chat SSE, recommandations, veille DuckDuckGo/Bing) continue
d'appeler ces fonctions sans changement ; elles utilisent le modèle RAPIDE
(OLLAMA_MODEL_RAPIDE), comme avant. Les nouveaux modules appellent directement
services.llm_service en choisissant leur modèle.
"""
from services import llm_service
from services.llm_service import LLMIndisponibleError  # noqa: F401 (réexporté pour les appelants)


def precharger_modele():
    llm_service.precharger(llm_service.modele_rapide())


def generer_reponse_sync(messages, temperature=0.3, max_tokens=None, num_ctx=4096):
    return llm_service.generer(
        messages, modele=llm_service.modele_rapide(), temperature=temperature,
        num_predict=max_tokens, num_ctx=num_ctx,
    )


def generer_reponse_stream(messages, temperature=0.3, num_ctx=4096, max_tokens=110):
    return llm_service.generer_stream(
        messages, modele=llm_service.modele_rapide(), temperature=temperature,
        num_predict=max_tokens, num_ctx=num_ctx,
    )
