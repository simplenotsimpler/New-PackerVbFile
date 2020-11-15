# New-PackerVbFile

## SYNOPSIS
Creates a new Packer JSON file to build a local VirtualBox Ubuntu machine.

## SYNTAX

```
New-PackerVbFile [-VbVmName] <String> [-IsoChecksum] <String> [-IsoUrl] <String> [[-ShutdownTimeOut] <String>]
 [[-Vcpus] <String>] [[-Memory] <String>] [[-HardDriveInterface] <String>] [[-DiskSize] <String>]
 [[-Vram] <String>] [[-Headless] <String>] [[-HttpDirectory] <String>] [[-OutFile] <FileInfo>] [-StartLog]
 [[-LogFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates a new Packer JSON file to build a local VirtualBox Ubuntu machine by merging parameters into the Packer file.
This eliminates the need to use the -var-file option.

## EXAMPLES

### EXAMPLE 1
```
$PackerParams = @{
  VbVmName = "ubu-test"
  IsoCheckSum = "443511f6bf12402c12503733059269a2e10dec602916c0a75263e5d990f6bb93"
  IsoUrl="https://releases.ubuntu.com/20.04.1/ubuntu-20.04.1-live-server-amd64.iso"
}
```

New-PackerVbFile @PackerParams

## PARAMETERS

### -VbVmName
Name of VirtualBox virtual machine

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsoChecksum
Checksum for the Ubuntu ISO URL.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsoUrl
Path to the Ubuntu ISO URL.
To save on time downloading, download locally and use a local path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShutdownTimeOut
Packer duration string | ex: "1h5m2s"

Manually set the amount of time for Packer to wait before shutting down machine.

Note: if running apt update, apt upgrade and installing packages, allow enough time for this to complete.

Minimum recommended time is 40 minutes (40m).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 40m
Accept pipeline input: False
Accept wildcard characters: False
```

### -Vcpus
Number of virtual CPUs

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 2
Accept pipeline input: False
Accept wildcard characters: False
```

### -Memory
Amount of memory in MB

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 2048
Accept pipeline input: False
Accept wildcard characters: False
```

### -HardDriveInterface
Hard drive controller, e.g.
SATA, IDE, SCSI, PCIe

PCIe results in NVMe controller.
See Packer and VirtualBox documentation for additional details.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: Sata
Accept pipeline input: False
Accept wildcard characters: False
```

### -DiskSize
Disk size in MB

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 32768
Accept pipeline input: False
Accept wildcard characters: False
```

### -Vram
Amount of VRAM in MB

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 37
Accept pipeline input: False
Accept wildcard characters: False
```

### -Headless
true or false.
Default is true.
Use false for troubleshooting.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -HttpDirectory
HTTP directory where store cloud-init user-data and meta-data files

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: Http
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
Specifies the name and path for the JSON-based Packer file.
By default, it creates a file named packer-local-ubuntu.json in the folder where the script is invoked.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: ("$PWD\packer-local-ubuntu.json")
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartLog
Switch.
Use this if you want an independent log when this script runs.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFile
Path to log file.
If not specified, defaults to "logs\$ModuleName-$LogDate.log".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to New-PackerVbFile.
## OUTPUTS

### Packer JSON file.
## NOTES
Since building a local VirtualBox machine and SSH typically times out, this uses the none communicator.

This configures a second NIC because using SSH to a host-only adapter is more reliable than depending on port forwarding, especially if you're in a corporate enviroment.
You'll need to configure a static IP of the 192.168.56.x format.

## RELATED LINKS

[https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)

[https://www.virtualbox.org/](https://www.virtualbox.org/)

[https://www.packer.io/](https://www.packer.io/)

[https://www.packer.io/docs/builders/virtualbox/iso](https://www.packer.io/docs/builders/virtualbox/iso)

[https://github.com/simplenotsimpler/New-Autoinstall](https://github.com/simplenotsimpler/New-Autoinstall)

[https://github.com/simplenotsimpler/Invoke-PackerBuildVbVm](https://github.com/simplenotsimpler/Invoke-PackerBuildVbVm)

[https://github.com/simplenotsimpler/Deploy-VbVm](https://github.com/simplenotsimpler/Deploy-VbVm)

