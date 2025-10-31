function Emoji {
    <#
    .SYNOPSIS
        Safe dispatcher function for emoji-related commands.
    
    .DESCRIPTION
        Provides a simplified interface to emoji functions with verb whitelisting
        and script validation. Only allows safe, approved verbs to be executed.
    
    .PARAMETER Action
        The action to perform (Get, Search, Update, Copy)
    
    .PARAMETER Query
        Query parameter for Search or Copy action
    
    .PARAMETER Category
        Category filter for Get action
    
    .PARAMETER Limit
        Limit the number of results
    
    .EXAMPLE
        Emoji Get
        Same as Get-Emoji
    
    .EXAMPLE
        Emoji Search "smile"
        Same as Search-Emoji -Query "smile"
    
    .EXAMPLE
        Emoji Update
        Same as Update-EmojiDataset
    
    .EXAMPLE
        Emoji Copy "smile"
        Same as Copy-Emoji -Query "smile"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Get', 'Search', 'Update', 'List', 'Copy', 'Export', 'Pick', 'Join')]
        [string]$Action,
        
        [Parameter(Mandatory = $false, Position = 1)]
        [string]$Query,
        
        [Parameter(Mandatory = $false)]
        [string]$Category,
        
        [Parameter(Mandatory = $false)]
        [int]$Limit = 0,
        
        [Parameter(Mandatory = $false)]
        [string[]]$Emojis
    )
    
    # Whitelisted verbs for security
    $whitelistedVerbs = @('Get', 'Search', 'Update', 'List', 'Copy', 'Export', 'Pick', 'Join')
    
    # Validate action is whitelisted
    if ($Action -notin $whitelistedVerbs) {
        Write-Error "Action '$Action' is not allowed. Permitted actions: $($whitelistedVerbs -join ', ')"
        return
    }
    
    # Validate inputs (no script injection)
    if ($Query -match '[;&|<>$`]') {
        Write-Error "Invalid characters detected in query. Query must not contain script operators."
        return
    }
    
    if ($Category -match '[;&|<>$`]') {
        Write-Error "Invalid characters detected in category. Category must not contain script operators."
        return
    }
    
    # Dispatch to appropriate function
    try {
        switch ($Action) {
            'Get' {
                $params = @{}
                if ($Category) { $params['Category'] = $Category }
                if ($Limit -gt 0) { $params['Limit'] = $Limit }
                Get-Emoji @params
            }
            'List' {
                # Alias for Get
                $params = @{}
                if ($Category) { $params['Category'] = $Category }
                if ($Limit -gt 0) { $params['Limit'] = $Limit }
                Get-Emoji @params
            }
            'Search' {
                if (-not $Query) {
                    Write-Error "Search action requires a query parameter."
                    return
                }
                $params = @{ Query = $Query }
                if ($Limit -gt 0) { $params['Limit'] = $Limit }
                Search-Emoji @params
            }
            'Update' {
                Update-EmojiDataset
            }
            'Copy' {
                if (-not $Query) {
                    Write-Error "Copy action requires a query parameter."
                    return
                }
                Copy-Emoji -Query $Query
            }
            'Export' {
                Write-Host "Use Export-Emoji function directly for full control over export options." -ForegroundColor Cyan
                Write-Host "Example: Export-Emoji -Format HTML -OutputPath 'emojis.html'" -ForegroundColor Yellow
            }
            'Pick' {
                $params = @{}
                if ($Category) { $params['Category'] = $Category }
                Show-EmojiPicker @params
            }
            'Join' {
                if (-not $Emojis -or $Emojis.Count -lt 2) {
                    Write-Error "Join action requires at least 2 emojis. Use -Emojis parameter."
                    Write-Host "Example: Emoji Join -Emojis '👨','👩','👧'" -ForegroundColor Yellow
                    return
                }
                Join-Emoji -Emojis $Emojis
            }
        }
    }
    catch {
        Write-Error "Failed to execute Emoji $Action : $_"
    }
}

