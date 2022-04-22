/*
	DESCRIPTION:
		Packer Template for building Remote Desktop Session Host image.
		OS: Windows Server 2019
*/

packer {
    required_plugins {
        vsphere = {
            version = ">= 0.0.1"
            source = "github.com/hashicorp/vsphere"
        }
    }
}

variable "vcenter_server" {
    type = string
    default = "vcenter.home.arpa"
}

variable "esxi_host" {
    type = string
    default = "esxi01.home.arpa"
}

variable "vcenter_username" {
    type = string
    default = "administrator@vsphere.local"
}

variable "vcenter_password" {
    type = string
    default = "null"
}

variable "vm_name" {
    type = string
    default = "packer-win2019"
}

variable "disk_size" {
    type = string
    default = "102400"
}

variable "memory" {
    type = string
    default = "8192"
}

source "vsphere-iso" "rdsh-base" {
    boot_command = ["<enter>"]
    boot_wait = "3s"
    communicator = "ssh"
    disk_controller_type = ["lsilogic-sas"]
    storage {
        disk_size = "${var.disk_size}"
        disk_thin_provisioned = true
    }
    network_adapters {
        network = "VM Network"
        network_card = "vmxnet3"
    }
    floppy_files = [
        "./answer_files/server-2019/Autounattend.xml",
        "./scripts/openssh.ps1",
        "./scripts/windows-vmtools.ps1"
    ]
    guest_os_type = "windows2019srv_64Guest"
    iso_url = "SW_DVD9_Win_Server_STD_CORE_2019_64Bit_English_DC_STD_MLF_X21-96581.iso"
    iso_checksum = "sha256:61a391f0dc98e703da674df3c984ac2eb432ff757f949385360e68476c920478"
    iso_paths = [
        "[] /usr/lib/vmware/isoimages/windows.iso"
    ]
    RAM = "${var.memory}"
    CPUs = 4
    ssh_username = "Administrator"
	ssh_password = "vagrant"
	ssh_timeout = "2h"
    vm_name = "${var.vm_name}"
    firmware = "efi-secure"
    vcenter_server = "${var.vcenter_server}"
    username = "${var.vcenter_username}"
    password = "${var.vcenter_password}"
    host = "${var.esxi_host}"
}

build {
    sources = ["source.vsphere-iso.rdsh-base"]

    provisioner "file" {
        destination = "C:\\PackerTemp\\"
        source      = "./installers/"
    }

    provisioner "powershell" {
        scripts = ["./scripts/install_roles.ps1"]
    }

    provisioner "windows-restart" {}

    provisioner "powershell" {
        scripts = ["./scripts/provision_image.ps1"]
    }
}
