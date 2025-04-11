# Imposta il branch principale e i protetti
$mainBranch = "main"
$protectedBranches = @("main", "master", "develop", "staging", "release", "Prova1","backupV/1.1")

# Verifica che sia un repo Git
if (-not (Test-Path ".git")) {
    Write-Host "Errore: non sei in una cartella Git." -ForegroundColor Red
    exit
}

# Aggiorna dati remoti
git fetch --prune

# Checkout al main branch
git checkout $mainBranch

# === Pulizia branch locali ===
$localBranches = git branch --merged | Where-Object {
    ($_ -notmatch "\*") -and ($protectedBranches -notcontains $_.Trim())
}

if ($localBranches.Count -eq 0) {
    Write-Host "`nNessun branch locale da eliminare." -ForegroundColor Yellow
} else {
    Write-Host "`nBranch locali mergiati da eliminare:`n" -ForegroundColor Cyan
    $localBranches | ForEach-Object { Write-Host $_ }git chech

    $confirmLocal = Read-Host "Vuoi eliminarli? (s/N)"
    if ($confirmLocal -eq 's') {
        $localBranches | ForEach-Object {
            $branchName = $_.Trim()
            git branch -d $branchName
        }
    }
}

# === Pulizia branch remoti ===
# Ottieni lista dei branch remoti
$remoteBranchesRaw = git branch -r | ForEach-Object { $_.Trim() }

# Filtra fuori quelli protetti o legati al main
$remoteBranches = $remoteBranchesRaw | Where-Object {
    ($_ -notmatch "/($($protectedBranches -join '|'))$") -and ($_ -notmatch "->")
}

# Ottieni lista dei branch mergiati sul remoto
$mergedRemoteBranches = @()
foreach ($remote in $remoteBranches) {
    $remoteShort = $remote -replace "^origin/", ""
    $isMerged = git branch -r --merged origin/$mainBranch | Select-String "origin/$remoteShort"
    if ($isMerged) {
        $mergedRemoteBranches += $remoteShort
    }
}

if ($mergedRemoteBranches.Count -eq 0) {
    Write-Host "`nNessun branch remoto mergiato da eliminare." -ForegroundColor Yellow
} else {
    Write-Host "`nBranch remoti mergiati pronti per l'eliminazione:`n" -ForegroundColor Cyan
    $mergedRemoteBranches | ForEach-Object { Write-Host "origin/$_" }

    $confirmRemote = Read-Host "Vuoi eliminarli dal remoto? (s/N)"
    if ($confirmRemote -eq 's') {
        $mergedRemoteBranches | ForEach-Object {
            git push origin --delete $_
        }
    }
}

# === Pulizia riferimenti remoti obsoleti ===
Write-Host "`nPulizia dei riferimenti remoti obsoleti..." -ForegroundColor Cyan
git remote prune origin

Write-Host "`nPulizia completata." -ForegroundColor Green
