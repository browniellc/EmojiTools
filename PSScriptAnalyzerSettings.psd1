@{
    # Severity levels: Error, Warning, Information
    Severity = @('Error', 'Warning')

    # Exclude specific rules
    ExcludeRules = @(
        # Allow unused parameters (common in PowerShell parameter sets)
        # 'PSReviewUnusedParameter',

        # Allow global variables (used for module state)
        # 'PSAvoidGlobalVars',

        # Allow using cmdlet aliases in examples
        # 'PSAvoidUsingCmdletAliases'
    )

    # Include specific rules
    IncludeRules = @(
        'PSUseApprovedVerbs',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingWMICmdlet',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingPositionalParameters',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUsePSCredentialType',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace',
        'PSUseCorrectCasing'
    )

    Rules = @{
        # Indentation
        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        }

        # Whitespace
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckPipeForRedundantWhitespace = $true
            CheckSeparator = $true
            CheckParameter = $false
        }

        # Casing
        PSUseCorrectCasing = @{
            Enable = $true
        }

        # Should Process
        PSUseShouldProcessForStateChangingFunctions = @{
            Enable = $true
        }

        # Cmdlet Aliases
        PSAvoidUsingCmdletAliases = @{
            Enable = $true
            # Allow specific aliases if needed
            # Whitelist = @('?', '%', 'foreach', 'where')
        }

        # Positional Parameters
        PSAvoidUsingPositionalParameters = @{
            Enable = $false  # Can be strict, disable if needed
            CommandAllowList = @('Select-Object', 'Where-Object', 'ForEach-Object')
        }

        # Provide Comment Help
        PSProvideCommentHelp = @{
            Enable = $true
            ExportedOnly = $true
            BlockComment = $true
            VSCodeSnippetCorrection = $true
            Placement = 'before'
        }
    }
}
