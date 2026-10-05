@echo off
REM ---------------------------------------------------------------------------
REM Démarre la veille IA automatique (actualités et offres toutes les 2 h,
REM universités une fois par jour) : un worker Celery qui exécute les tâches
REM + Celery Beat qui les déclenche à heure fixe. Les deux tournent en
REM arrière-plan (fenêtre masquée) ; relancer ce script les redémarre.
REM
REM Prérequis : Redis (Laragon) et Ollama démarrés.
REM Journaux : celery_worker.log et celery_beat.log ; les journaux du lancement
REM précédent sont conservés dans le dossier logs\ (horodatés), jamais effacés.
REM ---------------------------------------------------------------------------
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$dir = '%~dp0'.TrimEnd('\');" ^
  "$env:PYTHONIOENCODING = 'utf-8';" ^
  "Get-CimInstance Win32_Process -Filter \"Name='python.exe'\" | Where-Object { $_.CommandLine -match 'celery -A superapp_ia' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue };" ^
  "Start-Sleep -Seconds 2;" ^
  "$logs = Join-Path $dir 'logs'; New-Item -ItemType Directory -Force $logs | Out-Null;" ^
  "$stamp = Get-Date -Format 'yyyyMMdd_HHmmss';" ^
  "foreach ($f in 'celery_worker.log','celery_beat.log','celery_worker_out.log','celery_beat_out.log') { $p = Join-Path $dir $f; if (Test-Path $p) { Move-Item $p (Join-Path $logs ($stamp + '_' + $f)) -Force } };" ^
  "$py = Join-Path $dir 'venv\Scripts\python.exe';" ^
  "Start-Process -FilePath $py -ArgumentList '-m','celery','-A','superapp_ia','worker','-l','info','--pool=solo' -WorkingDirectory $dir -WindowStyle Hidden -RedirectStandardError (Join-Path $dir 'celery_worker.log') -RedirectStandardOutput (Join-Path $dir 'celery_worker_out.log');" ^
  "Start-Process -FilePath $py -ArgumentList '-m','celery','-A','superapp_ia','beat','-l','info' -WorkingDirectory $dir -WindowStyle Hidden -RedirectStandardError (Join-Path $dir 'celery_beat.log') -RedirectStandardOutput (Join-Path $dir 'celery_beat_out.log');"

echo.
echo Veille IA demarree (worker + planification toutes les 2 h).
echo Pour lancer une veille immediatement :
echo     venv\Scripts\python.exe manage.py veiller --actualites
echo     venv\Scripts\python.exe manage.py veiller --offres
