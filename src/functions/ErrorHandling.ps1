# Custom Exception Types and Error Handling for EmojiTools Module

<#
.SYNOPSIS
    Centralized error handling and custom exception types for EmojiTools.

.DESCRIPTION
    Provides typed exceptions and standardized error handling patterns to improve
    error diagnostics and ensure consistent error messaging across the module.
#>

# Define custom exception types
class EmojiToolsException : System.Exception {
    [string]$ErrorCode
    [hashtable]$Details

    EmojiToolsException([string]$message) : base($message) {
        $this.ErrorCode = "EMOJI_GENERAL_ERROR"
        $this.Details = @{}
    }

    EmojiToolsException([string]$message, [string]$errorCode) : base($message) {
        $this.ErrorCode = $errorCode
        $this.Details = @{}
    }

    EmojiToolsException([string]$message, [string]$errorCode, [hashtable]$details) : base($message) {
        $this.ErrorCode = $errorCode
        $this.Details = $details
    }
}

class DataNotFoundException : EmojiToolsException {
    DataNotFoundException([string]$message) : base($message, "EMOJI_DATA_NOT_FOUND") {}
    DataNotFoundException([string]$message, [hashtable]$details) : base($message, "EMOJI_DATA_NOT_FOUND", $details) {}
}

class CollectionNotFoundException : EmojiToolsException {
    CollectionNotFoundException([string]$collectionName) : base(
        "Collection '$collectionName' not found. Use Get-EmojiCollection to see available collections.",
        "EMOJI_COLLECTION_NOT_FOUND",
        @{ CollectionName = $collectionName }
    ) {}
}

class SourceNotFoundException : EmojiToolsException {
    SourceNotFoundException([string]$sourceName) : base(
        "Source '$sourceName' not found. Use Get-EmojiSource to list available sources.",
        "EMOJI_SOURCE_NOT_FOUND",
        @{ SourceName = $sourceName }
    ) {}
}

class SecurityValidationException : EmojiToolsException {
    SecurityValidationException([string]$message) : base($message, "EMOJI_SECURITY_VALIDATION_FAILED") {}
    SecurityValidationException([string]$message, [hashtable]$details) : base($message, "EMOJI_SECURITY_VALIDATION_FAILED", $details) {}
}

class NetworkException : EmojiToolsException {
    NetworkException([string]$message) : base($message, "EMOJI_NETWORK_ERROR") {}
    NetworkException([string]$message, [hashtable]$details) : base($message, "EMOJI_NETWORK_ERROR", $details) {}
}

class DataValidationException : EmojiToolsException {
    DataValidationException([string]$message) : base($message, "EMOJI_DATA_VALIDATION_FAILED") {}
    DataValidationException([string]$message, [hashtable]$details) : base($message, "EMOJI_DATA_VALIDATION_FAILED", $details) {}
}

function Write-EmojiError {
    <#
    .SYNOPSIS
        Centralized error handling function with consistent formatting and logging.

    .PARAMETER Exception
        The exception object to handle (can be custom EmojiToolsException or standard Exception)

    .PARAMETER Message
        Error message (used if Exception not provided)

    .PARAMETER Category
        PowerShell error category

    .PARAMETER ErrorCode
        Custom error code for tracking

    .PARAMETER Sanitize
        Whether to sanitize sensitive information from error messages

    .PARAMETER TargetObject
        The object that caused the error

    .EXAMPLE
        Write-EmojiError -Message "Failed to load data" -Category ResourceUnavailable

    .EXAMPLE
        try { ... } catch { Write-EmojiError -Exception $_.Exception }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [System.Exception]$Exception,

        [Parameter(Mandatory = $false)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ErrorCategory]$Category = [System.Management.Automation.ErrorCategory]::NotSpecified,

        [Parameter(Mandatory = $false)]
        [string]$ErrorCode,

        [Parameter(Mandatory = $false)]
        [switch]$Sanitize,

        [Parameter(Mandatory = $false)]
        [object]$TargetObject
    )

    # Determine message and error code
    $finalMessage = $Message
    $finalErrorCode = $ErrorCode

    if ($Exception) {
        if ($Exception -is [EmojiToolsException]) {
            $finalMessage = $Exception.Message
            $finalErrorCode = $Exception.ErrorCode

            # Add details to message if available
            if ($Exception.Details.Count -gt 0) {
                $detailsStr = ($Exception.Details.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" }) -join ", "
                Write-Verbose "Error details: $detailsStr"
            }
        }
        else {
            $finalMessage = if ($Message) { $Message } else { $Exception.Message }
        }
    }

    # Sanitize if requested or if dealing with security errors
    if ($Sanitize -or $Category -eq 'SecurityError') {
        $finalMessage = Clear-SensitiveInformation -Message $finalMessage
    }

    # Build error record
    $errorParams = @{
        Message = $finalMessage
        Category = $Category
    }

    if ($Exception) {
        $errorParams['Exception'] = $Exception
    }

    if ($TargetObject) {
        $errorParams['TargetObject'] = $TargetObject
    }

    if ($finalErrorCode) {
        $errorParams['ErrorId'] = $finalErrorCode
    }

    # Log to verbose stream for debugging
    Write-Verbose "ERROR [$finalErrorCode]: $finalMessage"

    # Write error
    Write-Error @errorParams
}

function Write-EmojiWarning {
    <#
    .SYNOPSIS
        Centralized warning handler with consistent formatting.

    .PARAMETER Message
        Warning message

    .PARAMETER WarningCode
        Optional warning code for tracking

    .PARAMETER Sanitize
        Whether to sanitize sensitive information

    .EXAMPLE
        Write-EmojiWarning -Message "Dataset is outdated" -WarningCode "DATA_OUTDATED"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$WarningCode,

        [Parameter(Mandatory = $false)]
        [switch]$Sanitize
    )

    $finalMessage = if ($Sanitize) {
        Clear-SensitiveInformation -Message $Message
    }
    else {
        $Message
    }

    if ($WarningCode) {
        Write-Verbose "WARNING [$WarningCode]: $finalMessage"
    }

    Write-Warning $finalMessage
}

function Clear-SensitiveInformation {
    <#
    .SYNOPSIS
        Internal helper to clear sensitive information from error messages.

    .PARAMETER Message
        The message to sanitize

    .OUTPUTS
        Sanitized message string
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $sanitized = $Message

    # Remove full file paths, keep only filename
    $sanitized = $sanitized -replace '[A-Za-z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*([^\\/:*?"<>|\r\n]+)', '$1'

    # Remove potential API keys (long alphanumeric strings)
    $sanitized = $sanitized -replace '\b[A-Za-z0-9_-]{32,}\b', '[REDACTED]'

    # Remove potential tokens
    $sanitized = $sanitized -replace '(?i)(token|key|secret|password)\s*[:=]\s*[^\s,;]+', '$1: [REDACTED]'

    # Sanitize URLs but keep domain
    $sanitized = $sanitized -replace 'https?://([^/\s]+)[^\s]*', 'https://$1/[...]'

    return $sanitized
}

function Invoke-SafeOperation {
    <#
    .SYNOPSIS
        Wraps operations with standardized error handling and retry logic.

    .PARAMETER ScriptBlock
        The operation to execute

    .PARAMETER ErrorMessage
        Custom error message if operation fails

    .PARAMETER ErrorCategory
        PowerShell error category

    .PARAMETER RetryCount
        Number of retry attempts (default: 0)

    .PARAMETER RetryDelaySeconds
        Delay between retries in seconds

    .PARAMETER SuppressErrors
        If specified, errors are written to verbose instead of error stream

    .EXAMPLE
        Invoke-SafeOperation -ScriptBlock { Import-Csv $path } -ErrorMessage "Failed to load data"

    .EXAMPLE
        Invoke-SafeOperation -ScriptBlock { Invoke-WebRequest $url } -RetryCount 3 -RetryDelaySeconds 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [string]$ErrorMessage = "Operation failed",

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ErrorCategory]$ErrorCategory = [System.Management.Automation.ErrorCategory]::NotSpecified,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 10)]
        [int]$RetryCount = 0,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 60)]
        [int]$RetryDelaySeconds = 1,

        [Parameter(Mandatory = $false)]
        [switch]$SuppressErrors
    )

    $attempt = 0
    $lastError = $null

    while ($attempt -le $RetryCount) {
        try {
            $attempt++

            if ($attempt -gt 1) {
                Write-Verbose "Retry attempt $attempt of $($RetryCount + 1)"
            }

            $result = & $ScriptBlock
            return $result
        }
        catch {
            $lastError = $_

            if ($attempt -le $RetryCount) {
                Write-Verbose "Attempt $attempt failed: $($_.Exception.Message). Retrying in $RetryDelaySeconds seconds..."
                Start-Sleep -Seconds $RetryDelaySeconds
            }
        }
    }

    # All attempts failed
    if ($SuppressErrors) {
        Write-Verbose "$ErrorMessage : $($lastError.Exception.Message)"
        return $null
    }
    else {
        Write-EmojiError -Exception $lastError.Exception -Message $ErrorMessage -Category $ErrorCategory
        return $null
    }
}

# Functions loaded via dot-sourcing in main module
