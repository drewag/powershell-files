# -----------------------------------------------------
# Author(s): Andrew Wagner, Joseph Coleman
# -----------------------------------------------------

function DoesMatchFilter( [string]$word, [string]$filter )
{
    $pattern = $filter.Replace( '*', '.+' )
    return $word -match "^$pattern"
}

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

# @return the maximum length prefix that is shared between all
# items in the array.
#
# For optimization this function assumes that all items will at
# least have the same prefix that is "$filter".
function GetCommonPrefixInArray( [array]$list, [string]$filter )
{
    $commonLetters = $list[0].Replace("'","")

    for( $i = 1; $i -lt $list.length; $i++ )
    {
        $el = $list[$i].Replace("'", "" )
        $commonLetters = GetCommonPrefix $el $commonLetters
        if( $commonLetters.length -eq $filter.length )
        {
            break
        }
    }
    return $commonLetters
}

function GetFilteredFileList( [string]$filter )
{
    $list = @()
    $testWord = $filter + '*'

    $origFilter = ""
    $numOrigComponents = $filter.Split( '/\' ).length
    if( $filter.Contains( '*' ) )
    {
        $origFilter = $filter
        $filter = $filter.Split( '*' )[0]
    }
    $numComponents = $numOrigComponents - $filter.Split( '/\' ).length + 1
    $base = $filter.Split( '/\' )[-1]
    $root = $filter.Substring( 0, $filter.length - $base.length )
    gci $testWord | foreach {
        $pertinentPath = [string]::join( '\', $_.ToString().Split( '\' )[-$numComponents..-1] )
        $newEl = $root + $base + $pertinentPath.Substring( $base.length )
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

    if( $origFilter.length -gt 0 )
    {
        $list += $origFilter
    }
    return $list
}
