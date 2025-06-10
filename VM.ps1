# Set up environment variables (analogous to Azure resource group/location)
$baseLocation = "D:\VMware"
$projectName = "DomainRG"
$templateName = "\Windows 10 x64.vmx"
$templatePath = "$baseLocation\$templateName"

# Create a project folder (like a resource group)
$projectPath = "$baseLocation\$projectName"
if (-not (Test-Path $projectPath)) {
    New-Item -Path $projectPath -ItemType Directory
}

# Define network and security group placeholders (for documentation/consistency)
$networkName = "dmzNetwork"
$nsgName = "myProdNSG"
# In VMware Workstation Pro, networking and firewalling are managed via the GUI or host OS

# Loop: Create and start 2 VMs from the template, attach a data disk
for ($i=1; $i -le 2; $i++) {
    $vmName = "VM$i"
    $vmFolder = "$projectPath\$vmName"
    $vmxSource = "$templatePath\$templateName.vmx"
    $vmxDest = "$vmFolder\$vmName.vmx"

    # Copy template folder to new VM folder
    Copy-Item -Path $templatePath -Destination $vmFolder -Recurse

    # Rename the .vmx file to match the VM name
    Rename-Item -Path "$vmFolder\$templateName.vmx" -NewName "$vmName.vmx"

    # Register the new VM
    & "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" register $vmxDest

    # Start the new VM
    & "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start $vmxDest

    # (Optional) Attach a new data disk (create a blank VMDK and add to .vmx)
    $diskPath = "$vmFolder\${vmName}_datadisk.vmdk"
    & "C:\Program Files (x86)\VMware\VMware Workstation\vmware-vdiskmanager.exe" -c -s 10GB -a lsilogic -t 1 $diskPath

    # Add disk entry to .vmx file
    Add-Content -Path $vmxDest -Value "`nhardDisk2.present = `"TRUE`"`nhardDisk2.fileName = `"$diskPath`""
}

# Note:
# - Networking, NSG, and subnet concepts are mostly managed via the VMware GUI or host OS for Workstation Pro.
# - This script assumes you have a prepared template VM folder and .vmx file.
# - For more advanced automation (networking, user/password, etc.), ESXi/vCenter is recommended.
