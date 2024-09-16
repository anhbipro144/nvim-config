
#Alias 
Set-Alias vim nvim
Set-Alias p pnpm
Set-Alias g git


#Oh my posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\nordcustom.omp.json" | Invoke-Expression


# Autocompletion
Import-Module PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Chord Ctrl+j  -Function NextHistory
Set-PSReadLineKeyHandler -Chord Ctrl+k  -Function PreviousHistory
