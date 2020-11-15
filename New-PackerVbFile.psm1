<#
.SYNOPSIS
Creates a new Packer JSON file to build a local VirtualBox Ubuntu machine.

.DESCRIPTION
Creates a new Packer JSON file to build a local VirtualBox Ubuntu machine by merging parameters into the Packer file. This eliminates the need to use the -var-file option.

.EXAMPLE
$PackerParams = @{
  VbVmName = "ubu-test"
  IsoCheckSum = "443511f6bf12402c12503733059269a2e10dec602916c0a75263e5d990f6bb93"
  IsoUrl="https://releases.ubuntu.com/20.04.1/ubuntu-20.04.1-live-server-amd64.iso"
}

New-PackerVbFile @PackerParams


.PARAMETER VbVmName
Name of VirtualBox virtual machine

.PARAMETER IsoChecksum
Checksum for the Ubuntu ISO URL.

.PARAMETER IsoUrl
Path to the Ubuntu ISO URL. To save on time downloading, download locally and use a local path.

.PARAMETER ShutdownTimeOut
Packer duration string | ex: "1h5m2s"

Manually set the amount of time for Packer to wait before shutting down machine.

Note: if running apt update, apt upgrade and installing packages, allow enough time for this to complete.

Minimum recommended time is 40 minutes (40m).

.PARAMETER Vcpus
Number of virtual CPUs

.PARAMETER Memory
Amount of memory in MB

.PARAMETER HardDriveInterface
Hard drive controller, e.g. SATA, IDE, SCSI, PCIe

PCIe results in NVMe controller. See Packer and VirtualBox documentation for additional details.

.PARAMETER DiskSize
Disk size in MB

.PARAMETER Vram
Amount of VRAM in MB

.PARAMETER Headless
true or false. Default is true. Use false for troubleshooting.

.PARAMETER HttpDirectory
HTTP directory where store cloud-init user-data and meta-data files

.PARAMETER OutFile
Specifies the name and path for the JSON-based Packer file. By default, it creates a file named packer-local-ubuntu.json in the folder where the script is invoked.

.PARAMETER StartLog
Switch. Use this if you want an independent log when this script runs.

.PARAMETER LogFile
Path to log file. If not specified, defaults to "logs\$ModuleName-$LogDate.log".

.INPUTS
None. You cannot pipe objects to New-PackerVbFile.

.OUTPUTS
Packer JSON file.

.NOTES
Since building a local VirtualBox machine and SSH typically times out, this uses the none communicator.

This configures a second NIC because using SSH to a host-only adapter is more reliable than depending on port forwarding, especially if you're in a corporate enviroment. You'll need to configure a static IP of the 192.168.56.x format.

.LINK
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7

.LINK
https://www.virtualbox.org/

.LINK
https://www.packer.io/

.LINK
https://www.packer.io/docs/builders/virtualbox/iso

.LINK
https://github.com/simplenotsimpler/New-Autoinstall

.LINK
https://github.com/simplenotsimpler/New-PackerVbFile

.LINK
https://github.com/simplenotsimpler/Invoke-PackerBuildVbVm

.LINK
https://github.com/simplenotsimpler/Deploy-VbVm

#>

function New-PackerVbFile {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$VbVmName,
    [Parameter(Mandatory = $true)]
    [string]$IsoChecksum,
    [Parameter(Mandatory = $true)]
    [string]$IsoUrl,
    [string]$ShutdownTimeOut = "40m",
    [string]$Vcpus = "2",
    [string]$Memory = "2048",
    [string]$HardDriveInterface = "sata",
    [string]$DiskSize = "32768",
    [string]$Vram = "37",
    [string]$Headless = "true",
    [string]$HttpDirectory = "http",
    [System.IO.FileInfo]$OutFile = ("$PWD\packer-local-ubuntu.json"),
    [Switch]$StartLog,
    [String]$LogFile
  )

  begin {


    $ErrorActionPreference = 'Stop'
    $VerbosePreference = "Continue"
    $ModuleName = $MyInvocation.MyCommand
    $VerbosePreference = "Continue"
    $PSDefaultParameterValues = @{"*:Verbose" = $True }
    $LogDate = (Get-Date -Format 'yyyy-MM-dd-HHmm')
    if (!$LogFile) {
      $LogFile = "logs\$ModuleName-$LogDate.log"
    }
    $Separator = "================================"

    if ($StartLog) {
      Start-Transcript $LogFile -Append
    }

    Write-Verbose $Separator
    Write-Verbose "     Begin $ModuleName Log"
    Write-Verbose $Separator


    Write-Verbose "Checking for VirtualBox"
    try {

      if(-Not([bool] (Get-Command -ErrorAction Ignore -Type Application VirtualBox))){
        throw "Unable to find VBoxManage executable. Please add it to your System Path."
      }
    }
    catch {
      Write-Error "$ModuleName::$_"
    }


    Write-Verbose "$ModuleName::Processing folder paths"
    # https://docs.oracle.com/en/virtualization/virtualbox/6.0/admin/vboxconfigdata.html

    if($IsWindows){
      $VbXmlPath="$HOME\.VirtualBox\VirtualBox.xml"
    }
    elseif ($IsMacOS) {
      $VbXmlPath="$HOME/Library/VirtualBox/VirtualBox.xml"
    }
    elseif ($IsLinux) {
      $VbXmlPath="$HOME/.config/VirtualBox/VirtualBox.xml"
    }

    try {
      if( -Not ($VbXmlPath | Test-Path -PathType Leaf) ){
        throw "VirtualBox.xml does not exist"
      }
    }
    catch {
      Write-Error "$ModuleName::$_"
    }

    $VbXml = [xml](Get-content $HOME\.VirtualBox\VirtualBox.xml)
    $VbMachineFolder = $VbXml.VirtualBox.Global.SystemProperties.defaultMachineFolder
    #Packer uses / for path separator regardless of OS. replace \ with /
    $VbFolder = (Join-Path $VbMachineFolder $VbVmName) -replace '\\', '/'

    #make sure also in Packer path format
    $IsoUrl = $IsoUrl -replace '\\', '/'
    $HttpDirectory = $HttpDirectory -replace '\\', '/'

  }

  process {

    Write-Verbose "$ModuleName::Generating Packer JSON file"

    #prefer braces at left margin of JSON and needs to be literal with heredoc
    $PackerVbUbuntu = @"
{
    "builders": [
      {
        "boot_command": [
            "<esc><esc><esc>",
            "<enter><wait>",
            "/casper/vmlinuz ",
            "root=/dev/sr0 ",
            "initrd=/casper/initrd ",
            "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
            "<enter>"
        ],
        "vm_name": "$($VbVmName)",
        "iso_checksum": "$($IsoChecksum)",
        "iso_url": "$($IsoUrl)",
        "communicator": "none",
        "virtualbox_version_file": "",
        "disable_shutdown": true,
        "shutdown_timeout": "$($ShutdownTimeOut)",
        "shutdown_command": "",
        "boot_wait": "5s",
        "cpus": "$($Vcpus)",
        "memory": "$($Memory)",
        "hard_drive_interface": "$($HardDriveInterface)",
        "disk_size": "$($DiskSize)",
        "guest_os_type": "Ubuntu_64",
        "guest_additions_mode": "disable",
        "headless": "$($Headless)",
        "http_directory": "$($HttpDirectory)",
        "output_directory": "$($VbFolder)",
        "type": "virtualbox-iso",

        "vboxmanage": [
            [
                "modifyvm",
                "{{.Name}}",
                "--vram",
                "$($Vram)",
                "--acpi",
                "on",
                "--ioapic",
                "on"
            ],
            [
                "storageattach",
                "{{.Name}}",
                "--storagectl",
                "SATA Controller",
                "--port" ,
                "0",
                "--nonrotational",
                "on"
            ],
            [
                "modifyvm",
                "{{.Name}}",
                "--mouse",
                "usbtablet"
            ],
            [
                "modifyvm",
                "{{.Name}}",
                "--graphicscontroller",
                "vmsvga",
                "--accelerate3d",
                "on"
            ],
            [
                "modifyvm",
                "{{.Name}}",
                "--nic2",
                "hostonly",
                "--hostonlyadapter2",
                "VirtualBox Host-Only Ethernet Adapter"
            ],
            [
                "modifyvm",
                "{{.Name}}",
                "--rtcuseutc",
                "on"
            ]
        ],
        "vboxmanage_post": [
            [
                "storageattach",
                "{{.Name}}",
                "--storagectl",
                "IDE Controller",
                "--port",
                "1",
                "--device",
                "0",
                "--type",
                "dvddrive",
                "--medium",
                "emptydrive"
            ]
        ],
        "keep_registered": true,
        "skip_export": true
    }
  ]
}
"@
  }

  end {
    #don't use convertto-json since we're using a literal heredoc
    $PackerVbUbuntu | Out-File $OutFile

    Write-Verbose $Separator
    Write-Verbose "      End $ModuleName"
    Write-Verbose $Separator

    if ($StartLog) {
      Stop-Transcript
    }

  }
}
