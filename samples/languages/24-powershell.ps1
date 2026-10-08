<#
.SYNOPSIS
    PowerShell language tour.

.DESCRIPTION
    Covers advanced functions, parameter validation, pipelines,
    classes, enums, error handling and splatting.

.PARAMETER Severity
    One of Debug, Info, Warning, Error.

.EXAMPLE
    Get-RecentLog -Take 5 -Severity Error

.NOTES
    Throws [System.ArgumentException] when Take is negative.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

enum Severity {
    Debug = 1
    Info = 2
    Warning = 3
    Error = 4
}

class LogEntry {
    [string] $Message
    [Severity] $Severity = [Severity]::Info
    [string[]] $Tags = @()

    LogEntry([string] $message) {
        if ([string]::IsNullOrWhiteSpace($message)) {
            throw [System.ArgumentException]::new('message required')
        }
        $this.Message = $message   # inline comment
    }

    [string] ToString() {
        return "[{0}] {1} ({2} tags)" -f $this.Severity, $this.Message, $this.Tags.Count
    }
}

function Get-RecentLog {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [LogEntry[]] $Entry,

        [ValidateRange(1, 100)]
        [int] $Take = 5,

        [Severity] $Severity = [Severity]::Warning
    )

    begin { $results = [System.Collections.Generic.List[string]]::new() }

    process {
        foreach ($item in $Entry) {
            if ($item.Severity -ge $Severity) { $results.Add($item.Message) }
        }
    }

    end {
        return $results | Select-Object -First $Take
    }
}

function Get-Description {
    param([int] $Count, [Severity] $Severity)

    switch ($Severity) {
        ([Severity]::Error)   { 'failing'; break }
        ([Severity]::Warning) { if ($Count -gt 100) { 'busy' } else { 'ok' }; break }
        default               { if ($Count -eq 0) { 'empty' } else { 'ok' } }
    }
}

try {
    $entries = @([LogEntry]::new('hello'), [LogEntry]::new('world'))
    $params = @{ Take = 2; Severity = [Severity]::Info }
    $entries | Get-RecentLog @params | Write-Output
}
catch [System.ArgumentException] {
    Write-Error "bad argument: $($_.Exception.Message)"
}
finally {
    Write-Verbose 'done'
}
