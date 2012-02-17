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
