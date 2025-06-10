# Set the correct template name and path
$templateName = "Windows 10 x64"
$templatePath = "D:\VMware"
$templateVMX = "$templatePath\$templateName.vmx"

# Set your project folder for new VMs
$projectName = "DomainRG"
$baseLocation = "D:\VMware"
$projectPath = "$baseLocation\$projectName"

# Create the project folder if it doesn't exist
if (-not (Test-Path $projectPath)) {
    New-Item -Path $projectPath -ItemType Directory
}

for ($i=1; $i -le 2; $i++) {
    $vmName = "VM$i"
    $vmFolder = "$projectPath\$vmName"
    New-Item -Path $vmFolder -ItemType Directory

    # Copy all files needed for the VM (all files with the template name prefix)
    Get-ChildItem -Path $templatePath -Filter "$templateName*" | 
        Copy-Item -Destination $vmFolder

    $vmxDest = "$vmFolder\$templateName.vmx"

    # Start the new VM (no register needed)
    & "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start $vmxDest
}
