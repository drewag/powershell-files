# -----------------------------------------------------
# Author(s): Andrew Wagner, Joseph Coleman
# -----------------------------------------------------

function GetHistoryItem([int]$item)
{
    (Get-History $item).CommandLine
}

function GetCommonPrefix( [string]$first, [string]$second )
{
    $common = ""
    for( $i=0; ( $i -lt $first.length ) -and ( $i -lt $second.length ); $i++ )
    {
        if( $first[$i] -eq $second[$i] )
        {
            $common += $first[$i];
        }
        else
        {
            break;
        }
    }
    return $common
}

function GetCommonPrefixInArray( [array]$list )
{
    $commonLetters = $list[0].Replace("'","")

    #Write-Host
    $list | foreach {
        $_ = $_.Replace("'", "" )
        #Write-Host $_
        $commonLetters = GetCommonPrefix $_ $commonLetters
    }
    return $commonLetters
}

function GetFilteredFileList( [string]$filter )
{
    $list = @()
    $basename = $filter.Split( '/\' )[-1]
    $testWord = $filter + '*'
    gci $testWord | foreach {
        $newEl = $filter + $_.name.Substring( $basename.length )
        if( $newEl.Contains( ' ' ) )
        {
            if( !$filter.Contains( ' ' ) )
            {
                if( !$newEl.StartsWith("'") )
                {
                    $newEl = "'" + $newEl
                }
                if( !$newEl.EndsWith("'") )
                {
                    $newEl += "'"
                }
            }
        }
        #if( Test-Path $newEl -pathType container )
        #{
        #    $newEl += '\'
        #}
        $list += $newEl
    }
    return $list
}
