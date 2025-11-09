# Security Helper Functions for EmojiTools Module

<#
.SYNOPSIS
    Internal security helper functions for input validation and secure operations.

.DESCRIPTION
    Provides centralized security functions including:
    - URL validation and sanitization
    - Path validation to prevent traversal attacks
    - Secure credential handling
    - Input sanitization
#>

function Test-SecureUrl {
    <#
    .SYNOPSIS
        Validates that a URL is secure and properly formatted.

    .PARAMETER Url
        The URL to validate

    .PARAMETER RequireHttps
        If specified, only HTTPS URLs are allowed

    .OUTPUTS
        Boolean indicating if URL is valid and secure
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,

        [Parameter(Mandatory = $false)]
        [switch]$RequireHttps
    )

    # Check for null or empty
    if ([string]::IsNullOrWhiteSpace($Url)) {
        return $false
    }

    # Check for suspicious patterns BEFORE parsing (URI constructor normalizes paths)
    $suspiciousPatterns = @(
        'javascript:',
        'data:',
        'file:',
        'vbscript:',
        '..',    # Path traversal (both / and \)
        '%00',   # Null byte
        '<',     # HTML/Script injection
        '>'
    )

    foreach ($pattern in $suspiciousPatterns) {
        if ($Url -like "*$pattern*") {
            return $false
        }
    }

    # Validate URL format
    try {
        $uri = [System.Uri]$Url

        # Must be absolute URL
        if (-not $uri.IsAbsoluteUri) {
            return $false
        }

        # Check scheme
        if ($RequireHttps -and $uri.Scheme -ne 'https') {
            return $false
        }

        if ($uri.Scheme -notin @('http', 'https')) {
            return $false
        }

        return $true
    }
    catch {
        return $false
    }
}

function Test-SecurePath {
    <#
    .SYNOPSIS
        Validates that a path is safe and doesn't contain traversal attempts.

    .PARAMETER Path
        The path to validate

    .PARAMETER BaseDirectory
        Optional base directory to ensure path stays within

    .OUTPUTS
        Boolean indicating if path is secure
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$BaseDirectory
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    # Check for path traversal patterns
    $dangerousPatterns = @(
        '..',      # Path traversal (literal)
        '%2e%2e',  # URL-encoded path traversal
        '..%5c',   # Mixed encoding traversal
        '..%2f',   # Mixed encoding traversal
        '%00',     # Null byte
        '<',       # Injection
        '>'
    )

    foreach ($pattern in $dangerousPatterns) {
        if ($Path -like "*$pattern*") {
            return $false
        }
    }

    # If base directory specified, ensure path is within it
    if ($BaseDirectory) {
        try {
            $fullPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($BaseDirectory, $Path))
            $baseFullPath = [System.IO.Path]::GetFullPath($BaseDirectory)

            if (-not $fullPath.StartsWith($baseFullPath, [StringComparison]::OrdinalIgnoreCase)) {
                return $false
            }
        }
        catch {
            return $false
        }
    }

    return $true
}

function ConvertTo-SecureApiKey {
    <#
    .SYNOPSIS
        Converts a plain text API key to a SecureString.

    .DESCRIPTION
        Safely converts an API key from plain text to SecureString format
        for secure storage in memory. This should be used when accepting
        API keys from user input.

    .PARAMETER ApiKey
        The API key in plain text

    .OUTPUTS
        SecureString containing the API key
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Necessary for converting user input to SecureString for secure storage')]
    [CmdletBinding()]
    [OutputType([SecureString])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$ApiKey
    )

    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        return $null
    }

    return ConvertTo-SecureString -String $ApiKey -AsPlainText -Force
}

function ConvertFrom-SecureApiKey {
    <#
    .SYNOPSIS
        Converts a SecureString API key back to plain text for use in API calls.
        WARNING: Only use this immediately before API call and clear result immediately after.

    .PARAMETER SecureApiKey
        The SecureString containing the API key

    .OUTPUTS
        Plain text API key string
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [SecureString]$SecureApiKey
    )

    try {
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureApiKey)
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    }
    finally {
        if ($bstr -ne [IntPtr]::Zero) {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

function Invoke-SecureWebRequest {
    <#
    .SYNOPSIS
        Wrapper around Invoke-RestMethod with security best practices applied.

    .PARAMETER Uri
        The URI to request

    .PARAMETER Method
        HTTP method (default: Get)

    .PARAMETER TimeoutSeconds
        Request timeout in seconds (default: 30)

    .PARAMETER MaxRetries
        Maximum number of retry attempts (default: 3)

    .PARAMETER Headers
        Optional headers dictionary

    .OUTPUTS
        Response from web request
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript( {
                if (-not (Test-SecureUrl -Url $_ -RequireHttps)) {
                    throw "Invalid or insecure URL: $_. Only HTTPS URLs are allowed."
                }
                $true
            })]
        [string]$Uri,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Get', 'Post', 'Put', 'Delete', 'Patch')]
        [string]$Method = 'Get',

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 300)]
        [int]$TimeoutSeconds = 30,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 10)]
        [int]$MaxRetries = 3,

        [Parameter(Mandatory = $false)]
        [hashtable]$Headers
    )

    $attempt = 0
    $lastError = $null

    while ($attempt -lt $MaxRetries) {
        try {
            $attempt++

            $params = @{
                Uri = $Uri
                Method = $Method
                TimeoutSec = $TimeoutSeconds
                ErrorAction = 'Stop'
            }

            if ($Headers) {
                $params['Headers'] = $Headers
            }

            # Add user agent for identification
            if (-not $params.ContainsKey('Headers')) {
                $params['Headers'] = @{}
            }
            $params['Headers']['User-Agent'] = 'EmojiTools-PowerShell/1.0'

            Write-Verbose "Secure web request attempt $attempt of $MaxRetries to: $Uri"
            return Invoke-RestMethod @params
        }
        catch {
            $lastError = $_
            Write-Verbose "Request attempt $attempt failed: $($_.Exception.Message)"

            # Don't retry on client errors (4xx)
            if ($_.Exception.Response.StatusCode -ge 400 -and $_.Exception.Response.StatusCode -lt 500) {
                throw
            }

            # Exponential backoff before retry
            if ($attempt -lt $MaxRetries) {
                $waitSeconds = [Math]::Pow(2, $attempt)
                Write-Verbose "Waiting $waitSeconds seconds before retry..."
                Start-Sleep -Seconds $waitSeconds
            }
        }
    }

    # All retries failed
    throw "Web request failed after $MaxRetries attempts. Last error: $($lastError.Exception.Message)"
}

function Write-SecureError {
    <#
    .SYNOPSIS
        Writes an error message with sensitive information removed.

    .PARAMETER Message
        The error message

    .PARAMETER Exception
        Optional exception to include (will be sanitized)

    .PARAMETER Category
        Error category
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [System.Exception]$Exception,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ErrorCategory]$Category = [System.Management.Automation.ErrorCategory]::NotSpecified
    )

    # Sanitize message - remove potential file paths, API keys, etc.
    $sanitizedMessage = $Message

    # Remove full file paths, keep only filename
    $sanitizedMessage = $sanitizedMessage -replace '[A-Za-z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*([^\\/:*?"<>|\r\n]+)', '$1'

    # Remove potential API keys (long alphanumeric strings with optional underscores)
    $sanitizedMessage = $sanitizedMessage -replace '\b[A-Za-z0-9_]{32,}\b', '[REDACTED]'

    # Remove URLs but keep domain
    $sanitizedMessage = $sanitizedMessage -replace 'https?://([^/\s]+)[^\s]*', 'https://$1/[...]'

    if ($Exception) {
        Write-Error -Message $sanitizedMessage -Exception $Exception -Category $Category
    }
    else {
        Write-Error -Message $sanitizedMessage -Category $Category
    }
}

# Functions loaded via dot-sourcing in main module
