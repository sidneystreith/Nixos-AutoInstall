# Nixos-AutoInstall

To automate the installation of NixOS on a server, you can use a combination of the `disko` tool and the `disko-install` script, 
along with a Nix flake that defines both the disk layout and the system configuration. This approach ensures a reproducible and fully automated setup, 
leveraging NixOS's declarative nature. Below is a step-by-step guide to achieve this:

---

### **Overview**
NixOS is a Linux distribution that uses the Nix package manager and allows system configurations to be defined declaratively. 
Automating its installation involves scripting the usual manual steps—booting, partitioning, mounting, configuring, and installing—into a streamlined process. 
The `disko` tool enables you to define disk layouts in Nix, while `disko-install` combines disk setup and system installation into a single command. 
Using a flake ensures all configurations are versioned and reproducible.

---

### **Steps to Automate NixOS Installation**

#### **1. Define the Configuration in a Flake**
A Nix flake is a structured way to define dependencies and configurations. You’ll create a `flake.nix` file that includes the `disko` module for disk partitioning and your system configuration.

- **Create a `disko-config.nix` file:**
  This defines the disk layout. Adjust the device path (e.g., `/dev/sda`) and partitioning scheme to match your server’s requirements.


- **Create a `configuration.nix` file:**
  This defines the system settings. Below is a minimal example; customize it for your server (e.g., add SSH, services, or users).

- **Host the Flake:**
  Commit these files to a Git repository (e.g., GitHub) so they can be accessed remotely. For example, if your repository is `github:myuser/myrepo`, the flake URL will be `github:myuser/myrepo#my-server`.

#### **2. Boot into the NixOS Installation Environment**
- Download the latest NixOS minimal installation ISO from the [NixOS website](https://nixos.org/download.html).
- Create a bootable USB drive (e.g., using `dd` or a tool like Rufus) or use PXE boot if your server supports it.
- Boot the server from the USB or network. This loads a live NixOS environment.

#### **3. Ensure Network Access**
- In the live environment, verify network connectivity (e.g., `ping nixos.org`). If DHCP is not enabled by default, configure networking manually:
  ```bash
  ip link
  ip addr add <your-ip>/<subnet> dev <interface>
  ip route add default via <gateway>
  echo "nameserver 8.8.8.8" > /etc/resolv.conf
  ```

#### **4. Run the Automated Installation**
- Use the `disko-install` command to apply the disk layout and install NixOS based on your flake:
  ```bash
  nix-env -iA nixos.disko # Install disko if not already present
  disko-install --flake github:CharlesSBL/Nixos-AutoInstall#my-server
  ```
- This command:
  - Fetches the flake from your repository.
  - Uses `disko` to partition and format the disk as defined in `disko-config.nix`.
  - Mounts the partitions (e.g., `/` and `/boot`).
  - Installs NixOS with the settings from `configuration.nix`.
  - Sets up the bootloader and completes the installation.

#### **5. Reboot**
- Once the installation finishes, reboot the server:
  ```bash
  reboot
  ```
- Remove the installation medium. The server will boot into your newly installed NixOS system.

---

### **Key Benefits**
- **Reproducibility:** The flake ensures the exact same configuration can be applied across multiple servers.
- **Automation:** After booting, a single command handles partitioning, configuration, and installation.
- **Flexibility:** Customize `disko-config.nix` and `configuration.nix` for different disk layouts or system setups.

---

### **Notes**
- **Disk Device:** Replace `/dev/sda` in `disko-config.nix` with the correct device (e.g., `/dev/nvme0n1` for NVMe drives). Use `lsblk` in the live environment to identify it.
- **Security:** For production, configure SSH keys instead of passwords and harden the system in `configuration.nix`.
- **Flake Availability:** Ensure the Git repository is accessible from the live environment. Alternatively, copy the flake to the server manually (e.g., via USB).
