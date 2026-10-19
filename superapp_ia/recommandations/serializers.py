"""Validation de l'entrée du module 1 (profil envoyé par Laravel)."""
from rest_framework import serializers


class OrientationEntreeSerializer(serializers.Serializer):
    serie_bac = serializers.CharField(max_length=10)
    moyenne = serializers.DecimalField(max_digits=4, decimal_places=2, min_value=0, max_value=20)
    passions = serializers.ListField(
        child=serializers.CharField(max_length=80), min_length=1, max_length=10,
    )
    ville = serializers.CharField(max_length=100, required=False, allow_blank=True, allow_null=True)
    # Facultatifs : affinent le score s'ils sont fournis (déjà présents dans le profil Laravel).
    matieres_fortes = serializers.ListField(
        child=serializers.CharField(max_length=80), required=False, max_length=10,
    )
    metiers_envisages = serializers.ListField(
        child=serializers.CharField(max_length=80), required=False, max_length=10,
    )
    mobilite = serializers.BooleanField(required=False)
    # Si fourni, les formations recommandées sont tracées dans la table `recommandations`.
    utilisateur_id = serializers.CharField(max_length=36, required=False)

    def validate_serie_bac(self, valeur):
        # 's2 ' -> 'S2' : même écriture que dans formations.series_acceptees.
        return valeur.strip().upper()

    def validate_passions(self, valeur):
        passions = [p.strip() for p in valeur if p.strip()]
        if not passions:
            raise serializers.ValidationError('Indique au moins une passion ou un centre d’intérêt.')
        return passions
