# -----------------------------------------------------
# Author(s): Andrew Wagner, Joseph Coleman
# -----------------------------------------------------

$wafCommands = @()
$wafOptions = @()

function GarminWafTabExpansion( [string]$lastBlock )
{
    switch -regex ( $lastBlock )
    {
        '^(\.\\)?waf .*?(-\S*)$'
        {
            GarminWafOptions( $matches[2] )
        }
        '^(\.\\)?waf .*?(\S*)$'
        {
            GarminWafCommands( $matches[2] )
        }
        ' (--product=)(\S*)$'
        {
            $cmds = @()
            GarminWafCommands( $matches[2] ) | foreach {
                $cmds += $matches[1] + $_
            }
            $cmds
        }
    }
}

function GarminWafCommands( [string]$filter )
{
    if( $wafCommands.length -eq 0 )
    {
        $output = .\waf --help
        foreach( $line in $output )
        {
            if($line -match '^\s+(\w+)\s*:')
            {
                $cmd = $matches[1]
                if( $filter -and (DoesMatchFilter $cmd $filter) )
                {
                    $wafCommands += $cmd
                }
                elseif(-not $filter)
                {
                    $wafCommands += $cmd
                }
            }
        }
        [Array]::Sort([array]$wafCommands)
    }
    return $wafCommands
}

function GarminWafOptions( [string]$filter )
{
    if( $wafOptions.length -eq 0 )
    {
        $output = .\waf --help
        [regex]$regex = ' (-[\w-]*?)(?=[\, =:])'
        $matches = $regex.Matches( $output, [Text.RegularExpressions.RegExOptions]::Multiline )
        $matches | foreach {
            $cmd = $_.Groups[1].Value
            if( $filter -and (DoesMatchFilter $cmd $filter) )
            {
                $wafOptions += $cmd
            }
            elseif(-not $filter)
            {
                $wafOptions += $cmd
            }
        }
        [Array]::Sort([array]$wafOptions)
    }
    return $wafOptions
}
