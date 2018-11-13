[CmdletBinding()]

Param (
    [string]$Path = $HOME,
    [string]$Version
)

if (-not $Version) {
    $Version = try {
        (Invoke-WebRequest "https://storage.googleapis.com/kubernetes-release/release/stable.txt").Content.Trim()
    }
    catch {
        Write-Host "Uncaught exception: $_.Exception.Message"
    }
}

if (Test-Path $Path -PathType Container) {
    try {
        Start-BitsTransfer `
            "https://storage.googleapis.com/kubernetes-release/release/$($Version)/bin/windows/amd64/kubectl.exe" `
            -DisplayName "Downloading kubectl..." `
            -Destination $Path
    } catch {
        Write-Host "Uncaught exception: $_.Exception.Message"
    }
    
    Set-Item -Path Env:Path -Value ($Env:Path + ";$Path")

    if (-not (Test-Path -Path "$($HOME)\.kube")) {
        New-Item -ItemType Directory "$($HOME)\.kube" -Force
    }
}
else {
    Write-Error "Invalid path specified. -Path must specify a pre-existing directory."
}
