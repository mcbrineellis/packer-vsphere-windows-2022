packer {
  required_plugins {
    windows-update = {
      version = "0.14.1"
      source = "github.com/rgl/windows-update"
    }
  }
}

locals {
  build_by      = "Built by: HashiCorp Packer ${packer.version}"
  build_date    = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version = formatdate("MMDD.hhmm", timestamp())
}

source "vsphere-iso" "windows2022" {
    # Connection Configuration
    vcenter_server        = "${var.vcenter_server}"
    username              = "${var.vsphere_username}"
    password              = "${var.vsphere_password}"
    insecure_connection   = "true"
    datacenter            = "${var.vsphere_datacenter}"

    # Location Configuration
    vm_name               = "${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}-v${local.build_version}"
    folder                = "${var.vsphere_folder}"
    cluster               = "${var.vsphere_cluster}"
    datastore             = "${var.vsphere_datastore}"

    # Hardware Configuration
    CPUs                  = "${var.vm_cpu_cores}"
    RAM                   = "${var.vm_mem_size}"
    firmware              = "${var.vm_firmware}"
    
    # Enable nested hardware virtualization for VM. Defaults to false.
    NestedHV              = "false"
 
    # Boot Configuration
    boot_command          = [
      "<up><wait><up><wait><up><wait><up><wait><up><wait>"
    ]
    boot_wait             = "3s"

    # Floppy Disk Configuration
    floppy_files          = [
      "${path.root}/floppy/"
    ]

    # Shutdown Configuration
    shutdown_command      = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""

    # ISO Configuration
    iso_checksum          = "4f1457c4fe14ce48c9b2324924f33ca4f0470475e6da851b39ccbf98f44e7852"
    iso_url               = "https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
    iso_paths             = [
      "[] /vmimages/tools-isoimages/windows.iso"
    ]

    # VM Configuration
    guest_os_type         = "windows9Server64Guest"
    notes                 = "Version: v${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"
    disk_controller_type  = ["pvscsi"]
    storage {
      disk_size           = "${var.vm_disk_size}"
      disk_thin_provisioned = "true"
    }
    network_adapters {
      network             = "${var.vsphere_network}"
      network_card        = "vmxnet3"
    }

    # Communicator Configuration
    communicator          = "ssh"
    ssh_username          = "packer"
    ssh_password          = "${var.vm_admin_password}"
    ssh_timeout           = "20m"

    # Create as template
    convert_to_template   = "true"
}

build {
  sources = ["source.vsphere-iso.windows2022"]

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    script = "${path.root}/scripts/provision.ps1"
  }

  provisioner "windows-update" {
    filters = [
      "exclude:$_.Title -like '*VMware*'",
      "include:$true"
    ]
  }
}