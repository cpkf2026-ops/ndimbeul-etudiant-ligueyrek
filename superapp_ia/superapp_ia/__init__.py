import pymysql

# PyMySQL se fait passer pour MySQLdb afin que le backend "django.db.backends.mysql"
# fonctionne sans compiler mysqlclient (impossible sans toolchain C sous Windows).
pymysql.install_as_MySQLdb()

# Django vérifie `Database.version_info >= (1, 4, 0)` en pensant lire la version de
# mysqlclient — mais PyMySQL a son propre numéro de version (ex: 1.1.x), plus petit
# numériquement bien qu'il soit largement compatible. Sans cette ligne, Django refuse
# de démarrer avec "mysqlclient 1.4.0 or newer is required" alors que tout fonctionne.
pymysql.version_info = (1, 4, 6, 'final', 0)

from .celery import app as celery_app  # noqa: E402

__all__ = ('celery_app',)
