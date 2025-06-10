# Variables - based on your file structure
$templateName = "Windows 10 x64"
$templatePath = "D:\VMware"
$projectName = "DomainRG"
$baseLocation = "D:\VMware"
$projectPath = "$baseLocation\$projectName"

# Create project folder if it doesn't exist
if (-not (Test-Path $projectPath)) {
    New-Item -Path $projectPath -ItemType Directory -Force
}

# File extensions to copy (exclude .lck files and folders)
$includeFiles = @("*.vmx", "*.vmdk", "*.nvram", "*.vmsd", "*.vmxf", "*.vmem", "*.vmss", "*.vmsn", "*.log", "*.scoreboard")

for ($i=1; $i -le 2; $i++) {
    $vmName = "VM$i"
    $vmFolder = "$projectPath\$vmName"

    # Remove existing VM folder if it exists (clean slate)
    if (Test-Path $vmFolder) {
        Write-Host "Removing existing folder: $vmFolder"
        Remove-Item -Path $vmFolder -Recurse -Force
    }
    
    # Create new VM folder
    New-Item -Path $vmFolder -ItemType Directory -Force

    # Copy template files (excluding .lck files)
    Write-Host "Copying template files to: $vmFolder"
    
    # Copy each file type individually to avoid lock files
    foreach ($filePattern in $includeFiles) {
        $filesToCopy = Get-ChildItem -Path $templatePath -Filter "$templateName*" | Where-Object { 
            $_.Name -like $filePattern.Replace("*", "$templateName*") -and 
            $_.Name -notlike "*.lck*" 
        }
        
        foreach ($file in $filesToCopy) {
            Copy-Item -Path $file.FullName -Destination $vmFolder -Force
        }
    }

    # Verify VMX file exists before starting
    $vmxFile = "$vmFolder\$templateName.vmx"
    if (Test-Path $vmxFile) {
        Write-Host "Starting VM: $vmName"
        & "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start $vmxFile
    } else {
        Write-Error "VMX file not found: $vmxFile"
    }
}
