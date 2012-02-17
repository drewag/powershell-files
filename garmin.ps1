# -----------------------------------------------------
# Author(s): Andrew Wagner, Joseph Coleman
# -----------------------------------------------------

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
    }
}

function GarminWafCommands( [string]$filter )
{
    $cmdList = @()
    $output = .\waf --help
    foreach( $line in $output )
    {
        if($line -match '^\s+(\w+)\s*:')
        {
            $cmd = $matches[1]
            if( $filter -and $cmd.StartsWith($filter) )
            {
                $cmdList += $cmd
            }
            elseif(-not $filter)
            {
                $cmdList += $cmd
            }
        }
    }
    $cmdList | sort;
}

function GarminWafOptions( [string]$filter )
{
    $cmdList = @()
    $output = .\waf --help
    [regex]$regex = ' (-[\w-]*?)(?=[\, =:])'
    $matches = $regex.Matches( $output, [Text.RegularExpressions.RegExOptions]::Multiline )
    $matches | foreach {
        $cmd = $_.Groups[1].Value
        if( $filter -and $cmd.StartsWith($filter) )
        {
            $cmdList += $cmd
        }
        elseif(-not $filter)
        {
            $cmdList += $cmd
        }
    }
    $cmdList | sort;
}
