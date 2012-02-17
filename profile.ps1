# -----------------------------------------------------
# Author(s): Andrew Wagner, Joseph Coleman
# -----------------------------------------------------

# -----------------------------------------------------
# System Settings
# -----------------------------------------------------

# Set the Home directory
Remove-Variable -Force HOME
Set-Variable HOME $env:userprofile
(get-psprovider filesystem).home = $HOME

# -----------------------------------------------------
# Includes
# -----------------------------------------------------
. ~\Documents\WindowsPowerShell\git.ps1
. ~\Documents\WindowsPowerShell\util.ps1
. ~\Documents\WindowsPowerShell\garmin.ps1

# -----------------------------------------------------
# Aliases
# -----------------------------------------------------
# Remove ls alias to default to one in path
Remove-Item alias:ls

# -----------------------------------------------------
# Customization Variables
# -----------------------------------------------------
$PROMPT_COLOR = "green"
$PROMPT_GIT_COLOR = "white"
$MaximumHistoryCount = 2048
$historyPath = Join-Path (split-path $profile) history.clixml


# -----------------------------------------------------
# Function Callbacks
# -----------------------------------------------------
function Prompt
{
    Write-Host ($pwd) -nonewline -foregroundcolor $PROMPT_COLOR
    Write-Host (GitPrompt) -nonewline -foregroundcolor $PROMPT_GIT_COLOR
    Write-Host '>' -nonewline -foregroundcolor $PROMPT_COLOR
    return " "
}

Copy Function:\TabExpansion Function:\OriginalTabExpansion
function TabExpansion($line, $lastWord) {
    $LineBlocks = [regex]::Split($line, '[|;]')
    $lastBlock = $LineBlocks[-1]

    $list = @()
    switch -regex ($lastBlock) {
        '(^|\s)#(\d+)$'
        {
            $list += GetHistoryItem($matches[2])
        }
        '^\s*git '
        {
            $list += GitTabExpansion($lastBlock)
        }
        '^\s*(\.\\)?waf'
        {
            $list += GarminWafTabExpansion($lastBlock)
        }
        default
        {
            $list = OriginalTabExpansion $line $lastWord
        }
    }
    if( !$list -or $list.length -eq 0 )
    {
        $list = GetFilteredFileList $lastWord
    }
    $commonLetters = GetCommonPrefixInArray $list

    if( $commonLetters.Contains( ' ' ) -and
        !$lastWord.Contains( ' ' ) )
    {
        $commonLetters = "'" + $commonLetters + "'"
    }

    $list = @($commonLetters) + $list
    return $list

    #$oldX = [console]::CursorLeft
    #$oldY = [console]::CursorTop
#
#    $lineCount = 0
#    Write-Host $commonLetters
#    $list | foreach {
#        Write-Host $_
#        $lineCount++;
#    }
#    $prompt = prompt
#    Write-Host $prompt$line
#    $newY = $oldY + $lineCount + 1
#    [console]::setcursorposition($oldX, $newY )
    #Read-Host
}

# hook powershell's exiting event & hide the registration with -supportevent.
Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
    Get-History -Count $MaximumHistoryCount | Export-Clixml $historyPath
}

# load previous history, if it exists
if ((Test-Path $historyPath))
{
    Import-Clixml $historyPath | ? {$count++;$true} | Add-History
}
