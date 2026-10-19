# ---------------------------------------------------------------------------
# Installe (ou reinstalle) la tache Windows "Ndimbeul - Veille IA" : la veille
# (offres, stages, emplois, actualites) tourne toutes les 2 h, meme quand
# l'application est fermee. Aucun droit administrateur requis.
#
#   Installer   : powershell -ExecutionPolicy Bypass -File installer_veille_windows.ps1
#   Desinstaller: powershell -ExecutionPolicy Bypass -File installer_veille_windows.ps1 -Desinstaller
#   Voir l'etat : Planificateur de taches > Bibliotheque > "Ndimbeul - Veille IA"
#   Journal     : logs\veille_planifiee.log
# ---------------------------------------------------------------------------
param([switch]$Desinstaller)

$NomTache = 'Ndimbeul - Veille IA'

if ($Desinstaller) {
    Unregister-ScheduledTask -TaskName $NomTache -Confirm:$false -ErrorAction SilentlyContinue
    Write-Output "Tache '$NomTache' supprimee."
    exit 0
}

$Script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'veille_planifiee.ps1'

$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Script`""

# Premier passage dans 2 minutes, puis toutes les 2 heures, sans fin.
$declencheur = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(2) `
    -RepetitionInterval (New-TimeSpan -Hours 2)

# - tourne aussi sur batterie (PC portable) ;
# - StartWhenAvailable : si le PC etait eteint ou en veille a l'heure prevue, le passage
#   a lieu des qu'il est rallume ;
# - jamais deux passages en meme temps ; arret de securite apres 1 h.
$reglages = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Hours 1)

Register-ScheduledTask -TaskName $NomTache -Action $action -Trigger $declencheur -Settings $reglages `
    -Description 'Ndimbeul Etudiant : recherche des offres, stages, emplois et actualites (Tavily + IA locale) toutes les 2 h.' `
    -Force | Out-Null

$tache = Get-ScheduledTask -TaskName $NomTache
$info = Get-ScheduledTaskInfo -TaskName $NomTache
Write-Output "Tache '$NomTache' installee (etat : $($tache.State)). Prochain passage : $($info.NextRunTime)"
