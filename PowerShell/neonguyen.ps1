
#Alias 
Set-Alias vim nvim
Set-Alias g git
Set-Alias lg lazygit
Set-Alias p pnpm


#Oh my posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\nordcustom.omp.json" | Invoke-Expression


# Autocompletion
Import-Module PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Chord Ctrl+j  -Function NextHistory
Set-PSReadLineKeyHandler -Chord Ctrl+k  -Function PreviousHistory
