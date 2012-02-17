# -----------------------------------------------------
# Author(s): Andrew Wagner, Joseph Coleman
# -----------------------------------------------------

function GitPrompt
{
    if( IsCurrentDirectoryGitRepository )
    {
        $ret = ' (' + (GitBranch) + ')'
        $ret
    }
}

function IsCurrentDirectoryGitRepository
{
    if ((Test-Path ".git") -eq $TRUE) {
        return $TRUE
    }

    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + '/.git'
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $TRUE
        } else {
            $checkIn = $checkIn.parent
        }
    }

    return $FALSE
}

# Get the current branch
function GitBranch
{
    $currentBranch = ''
    git branch | foreach {
        if ($_ -match "^\* (.*)") {
            $currentBranch += $matches[1]
        }
    }
    return $currentBranch
}

function GitTabExpansion($lastBlock)
{
     switch -regex ($lastBlock)
     {

        #Handles git branch -x -y -z <branch name>
        'git branch -(d|D) (\S*)$'
        {
          GitLocalBranches($matches[2])
        }

        #handles git checkout <branch name>
        'git checkout (\S*)$'
        {
          GitAllBranches($matches[2])
        }

        #handles git merge <brancj name>
        'git merge (\S*)$'
        {
          GitLocalBranches($matches[2])
        }

        #handles git <cmd>
        #handles git help <cmd>
        'git (help )?(\S*)$'
        {
          GitCommands($matches[2])
        }

        #handles git push remote <branch>
        #handles git pull remote <branch>
        'git (push|pull) (\S+) (\S*)$'
        {
          GitLocalBranches($matches[3])
        }

        #handles git pull <remote>
        #handles git push <remote>
        'git (push|pull) (\S*)$'
        {
          GitRemotes($matches[2])
        }
    }	
}

function GitCommands($filter) {
    $cmdList = @()
    # Get the most common commands
    $output = git help
    foreach($line in $output) {
        if($line -match '^\s+(\w+)')
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
    [Array]::Sort([array]$cmdList)

    # Add all other commands below the most common so that the common
    # commands are prioritized
    $output = git help --all | grep -e '^ \+\w' | sed 's/\(\w\) \+/\1\n/g' | sed 's/^ *//'
    $output | sort | foreach {
        $cmd = $_.Trim()
        if( $cmdList -notcontains $cmd )
        {
            if( $filter -and $cmd.StartsWith( $filter ) )
            {
                $cmdList += $cmd
            }
            elseif( -not $filter )
            {
                $cmdList += $cmd
            }
        }
    }
    $cmdList
}

function GitRemotes( [string]$filter )
{
  if($filter) {
    git remote | where { $_.StartsWith($filter) }
  }
  else {
    git remote
  }
}

function GitAllBranches($filter)
{
   git branch -a | foreach {
      if( $_ -match "^\*?\s*(.*)" )
      {
        $branch = $matches[1] -replace '^remotes/origin/', ''
        $branch = $branch -replace ' ->.*', ''
        if( $filter -and $branch.StartsWith( $filter ) )
        {
          $branch
        }
        elseif(-not $filter)
        {
          $branch
        }
      }
   }
}

function GitLocalBranches($filter)
{
   git branch | foreach {
      if( $_ -match "^\*?\s*(.*)" )
      {
        $branch = $matches[1]
        if($filter -and $branch.StartsWith($filter) )
        {
          $branch
        }
        elseif(-not $filter)
        {
          $branch
        }
      }
   }
}
