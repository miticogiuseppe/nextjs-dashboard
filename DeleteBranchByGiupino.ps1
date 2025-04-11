# === Script per eliminare branch Git in modo interattivo ===

# Chiedi il nome del branch
$branch = Read-Host "Inserisci il nome del branch da eliminare (senza origin/)"

# Verifica che non sia vuoto
if ([string]::IsNullOrWhiteSpace($branch)) {
    Write-Host "Nome branch non valido." -ForegroundColor Red
    exit
}

# Mostra le opzioni
Write-Host "`nChe cosa vuoi fare con '$branch'?"
Write-Host "1. Elimina solo localmente"
Write-Host "2. Elimina solo dal remoto"
Write-Host "3. Elimina sia localmente che dal remoto"
$scelta = Read-Host "Scegli (1/2/3)"

switch ($scelta) {
    '1' {
        git branch -d $branch 2>$null
        if ($LASTEXITCODE -ne 0) {
            $forza = Read-Host "Branch non mergiato. Vuoi forzare la rimozione locale? (s/N)"
            if ($forza -eq 's') {
                git branch -D $branch
                Write-Host "Branch cancellato" -ForegroundColor Green
            }
        }
    }
    '2' {
        git push origin --delete $branch
    }
    '3' {
        git branch -d $branch 2>$null
        if ($LASTEXITCODE -ne 0) {
            $forza = Read-Host "Branch non mergiato. Vuoi forzare la rimozione locale? (s/N)"
            if ($forza -eq 's') {
                git branch -D $branch
                Write-Host "Branch cancellato" -ForegroundColor Green
            }
        }
        git push origin --delete $branch
    }
    default {
        Write-Host "Scelta non valida." -ForegroundColor Yellow
    }
}

Write-Host "`nOperazione completata." -ForegroundColor Green
