# ---------------------------------------------------------------------------
# Veille IA planifiee - lancee toutes les 2 h par le Planificateur de taches
# Windows (tache "Ndimbeul - Veille IA", voir installer_veille_windows.ps1),
# MEME QUAND L'APPLICATION EST FERMEE (il suffit que le PC soit allume).
#
#   1. demarre MySQL (Laragon) et Ollama s'ils ne tournent pas ;
#   2. lance "manage.py veiller --planifie" : offres puis actualites, via Tavily
#      et l'IA locale. Si Celery Beat vient deja de faire le passage (application
#      ouverte), celui-ci est ignore : jamais deux fois en 2 h, aucun credit Tavily
#      depense en double (voir veille/commun.py, reserver_passage) ;
#   3. ecrit le deroulement dans logs\veille_planifiee.log.
# ---------------------------------------------------------------------------
$Dossier = Split-Path -Parent $MyInvocation.MyCommand.Path
$DossierLogs = Join-Path $Dossier 'logs'
$Journal = Join-Path $DossierLogs 'veille_planifiee.log'
New-Item -ItemType Directory -Force $DossierLogs | Out-Null

function Ecrire([string]$Message) {
    Add-Content -Path $Journal -Encoding UTF8 -Value ('{0:yyyy-MM-dd HH:mm:ss}  {1}' -f (Get-Date), $Message)
}

function Ecoute([int]$Port) {
    [bool](Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
}

function Attendre([int]$Port, [int]$Secondes) {
    for ($i = 0; $i -lt $Secondes -and -not (Ecoute $Port); $i += 2) { Start-Sleep -Seconds 2 }
    Ecoute $Port
}

Ecrire '--- Debut de la veille planifiee'

# 1. MySQL (base partagee avec Laravel)
if (-not (Ecoute 3306)) {
    $mysqld = Get-ChildItem 'C:\laragon\bin\mysql\*\bin\mysqld.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($mysqld) {
        $config = Join-Path $mysqld.Directory.Parent.FullName 'my.ini'
        Start-Process -FilePath $mysqld.FullName -ArgumentList "--defaults-file=`"$config`"" -WindowStyle Hidden
        Ecrire "MySQL etait arrete : demarrage de $($mysqld.FullName)"
    }
    if (-not (Attendre 3306 60)) { Ecrire 'ECHEC : MySQL injoignable, veille annulee.'; exit 1 }
}

# 2. Ollama (IA locale)
if (-not (Ecoute 11434)) {
    Start-Process -FilePath "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe" -ArgumentList 'serve' -WindowStyle Hidden
    Ecrire 'Ollama etait arrete : demarrage.'
    if (-not (Attendre 11434 60)) { Ecrire 'ECHEC : Ollama injoignable, veille annulee.'; exit 1 }
}

# 3. La veille elle-meme
$env:PYTHONIOENCODING = 'utf-8'
$python = Join-Path $Dossier 'venv\Scripts\python.exe'
$sortie = & $python (Join-Path $Dossier 'manage.py') veiller --planifie 2>&1 | Out-String
Ecrire ($sortie.Trim())
Ecrire "--- Fin de la veille planifiee (code $LASTEXITCODE)"
exit $LASTEXITCODE
