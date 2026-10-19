@echo off
REM ===========================================================================
REM  Ndimbeul Etudiant - Lance TOUT le projet en un double-clic :
REM    Redis, Ollama (IA), Laravel (API), Django (IA), veille Celery (2 h)
REM    et l'application dans Chrome.
REM  Prerequis : Laragon demarre (MySQL) -> bouton "Start All".
REM  Chaque service s'ouvre dans sa propre fenetre "Ndimbeul - ...".
REM  Fermer ces fenetres arrete les services.
REM
REM  Application : la version COMPILEE (frontend\build\web) est servie si elle
REM  existe. Elle est beaucoup plus legere que "flutter run" (pas de compilateur
REM  Dart en memoire), indispensable sur un PC de 8-10 Go de RAM.
REM  Apres une modification du code Flutter, recompiler une fois :
REM      cd frontend  puis  flutter build web --release
REM ===========================================================================
setlocal
set RACINE=%~dp0
set RACINE=%RACINE:~0,-1%
set PHP=C:\laragon\bin\php\php-8.3.16-Win32-vs16-x64\php.exe
set REDIS_DIR=C:\laragon\bin\redis\redis-x64-5.0.14.1
set OLLAMA=%LOCALAPPDATA%\Programs\Ollama\ollama.exe
set PYTHON_IA=%RACINE%\superapp_ia\venv\Scripts\python.exe

echo [1/6] Redis...
REM 128 Mo suffisent (file de la veille + cache). volatile-lru : si la limite est atteinte,
REM seules les entrees du cache (qui expirent) sont effacees, jamais la file de la veille.
REM Lance par PowerShell, en arriere-plan : avec "start", redis-server s'arretait aussitot
REM sur ce PC (alors qu'il tient lance de cette facon). Journal : %TEMP%\redis_ndimbeul.log
powershell -NoProfile -Command "Start-Process -FilePath '%REDIS_DIR%\redis-server.exe' -ArgumentList '--maxmemory','128mb','--maxmemory-policy','volatile-lru' -WorkingDirectory '%REDIS_DIR%' -WindowStyle Hidden -RedirectStandardOutput '%TEMP%\redis_ndimbeul.log'"

echo [2/6] Ollama (IA locale)...
tasklist /fi "imagename eq ollama.exe" | find /i "ollama.exe" >nul
if errorlevel 1 (start "Ndimbeul - Ollama (IA)" /min cmd /k ""%OLLAMA%" serve") else (echo       deja demarre)

echo [3/6] API Laravel (port 8000)...
start "Ndimbeul - Laravel (8000)" /min /d "%RACINE%\backend" cmd /k "set PHP_CLI_SERVER_WORKERS=4&& "%PHP%" artisan serve --port=8000"

echo [4/6] Service IA Django (port 8001)...
start "Ndimbeul - Django IA (8001)" /min /d "%RACINE%\superapp_ia" cmd /k "set PYTHONIOENCODING=utf-8&& "%PYTHON_IA%" manage.py runserver 8001 --noreload"

echo [5/6] Veille IA automatique (Celery, toutes les 2 h)...
timeout /t 5 /nobreak >nul
call "%RACINE%\superapp_ia\demarrer_veille.bat" >nul

echo [6/6] Application dans Chrome (port 8090)...
if exist "%RACINE%\frontend\build\web\index.html" goto version_compilee
start "Ndimbeul - Flutter (Chrome)" /d "%RACINE%\frontend" cmd /k flutter run -d chrome --web-port 8090
echo       version compilee absente : mode developpement, 1 a 2 minutes de compilation.
goto fin

:version_compilee
start "Ndimbeul - Application (8090)" /min /d "%RACINE%\frontend\build\web" cmd /k ""%PYTHON_IA%" -m http.server 8090"
timeout /t 3 /nobreak >nul
start "" chrome http://localhost:8090
echo       version compilee (legere).

:fin
echo.
echo Tout est lance. L'application est sur :
echo     http://localhost:8090
timeout /t 10 >nul
