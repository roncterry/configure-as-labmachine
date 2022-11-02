# configure-as-labmachine

**TLDR:**

  * Perform a default openSUSE Leap or SLES/SLED installation. 

  * Download this project into the installed openSUSE Leap or SLE 15 image.

  * Run the `configure-as-labmachine.sh` script (as root or via sudo) to configure that image to be basically the standard SUSE Training lab machine image. (It can be run from a terminal in a GUI however it might be best to switch to a virtual terminal and run the command.)

**openSUSE Leap versions supported:** Leap 15.1/15.2/15.3/15.4

**SLES/SLED versions supported:** SLE15 SP1/SP2/SP3



# Modifying the Script's behavior and Output:

**Config File:**

The behaviors of the script can be modified by editing the `config/configure-as-labmachine.cfg` file. 

One important modification that will probably need to be done is to edit the `USER_LIST` variable to change the name of the default user that will be used or even add additional users to be configured in the same manner. (This is a space delimited list).

**CLI Arguments:**

The script can perform many different operations to configure the machine to be a "lab machine" some of which are standard some of which are optional.

When running the script you can control what operations are performed by using different arguments. If no arguments are supplied to the command then all standard operations will be performed. If any one of the standard operation is supplied as an argument only that operation will be performed. Optional operations will only be performed if the argument is supplied. Multiple optional operations can be supplied as a space delimited list and each will be performed.

**Example:**
    `configure-as-labmachine.sh [arg] [arg] ...`

<u>**Standard Operations:**</u>

|<u>Argument</u>    |<u>Description</u>                                                                                                                                 |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| **base_env-only** | Configure the base environment (sudo, default directories, wallpapers, LibreOffice color palettes)                                                |
| **packages-only** | Configure standard software repositories and install packages                                                                                     |
| **libvirt-only**  | Configure KVM and Libvirt                                                                                                                         |
| **tools-only**    | Install the labmachine tools into /usr/local/bin/                                                                                                 |
| **vbox-only**     | Install VirtualBox extensions                                                                                                                     |
| **user_env-only** | Configure the user(s') shell and GNOME environment and install user local copies of the standard GNOME Shell extensions (including into /etc/skel)|

<u>**Optional Operations:**</u>

|<u>Argument</u>    |<u>Description</u>                 |
|-------------------|-----------------------------------|
| **install-teams** | Add Teams repo and install Teams  |
| **install-insync**| Add Insync repo and install Insync|
| **install-zoom**  | Download and install Zoom         |


**Software Repositories:**

**Note**:  This automatically adds the following software repositories:

  * google-chrome
  * Cloud:Tools
  * X11:RemoteDesktop:x2go

If you would like to add the **packman** repo, edit the `config/configure-as-labmachine.cfg` file and uncomment and move the packman repo into the `ZYPPER_REPOS_LIST` variable. There are other optional and potentially desirable repos commented out as well. These can be uncommented and moved into the `ZYPPER_REPOS_LIST` variable in the same manner. You may add any additional repos to that variable as well (ensuring that the URL is correct for the distro).

**Custom RPM Packages to install:**

If you have additional custom RPM packages you would like installed you can place them in the `rpms` directory. They will be installed with zypper when after the standard repos and packages have been added and installed. (I.e. this is the way you would install the virtualbmc command - for Leap 15.3 and later the package must be downloaded form the Leap 15.1 repo.)

**Hook Directory for Custom Commands:**

If you have any custom scripts you would like to be run you can put them in the `include` directory and if they have the `.sh` filename extension they will be run at the end of the scripts operations.

# Additional Optional Tools:

Once the machine has been configured as a lab machine, if there are additional disks attached, the `create-and-mount-courses-disk.sh` and `create-and-mount-home-disk.sh` scripts can be used to automatically partition/format and then mount the additional disks on `/install/courses` and `/home` in the case that the additional disk space is needed for the lab environments to be installed and run (i.e. as in when using a standard OS image Azure where you need to add an additional disk to provide more disk space).
