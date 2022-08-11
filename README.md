# configure-as-labmachine

**TLDR:**

  * Perform a default openSUSE Leap or SLES/SLED installation. 

  * Download this project into the installed openSUSE Leap or SLE 15 image.

  * Run the `configure-as-labmachine.sh` script (as root or via sudo) to configure that image to be basically the standard SUSE Training lab machine image.

**openSUSE Leap versions supported:** Leap 15.1/15.2/15.3

**SLES/SLED versions supported:** SLE15 SP1/SP2/SP3



# Modifying the Script's behavior and Output:

**Config File:**

The behaviors of the script can be modified by editing the `config/configure-as-labmachine.cfg` file. 

One important modification that will probably need to be done is to edit the `USER_LIST` variable to change the name of the default user that will be used or even add additional users to be configured in the same manner. (This is a space delimited list).

**CLI Arguments:**

The script can perform many different operations to configure the machine to be a "lab machine" some of which are standard some of which are optional.

When running the script you can control what operations are performed by using different arguments. If no arguments are supplied to the command then all <u>standard</u> operations will be performed. Optional operations will <u>only</u> be performed if the argument is supplied.

**Example:**
    `configure-as-labmachine.sh [arg] [arg] ...`

<u>**Standard Operations:**</u>

|<u>Argument</u>   |<u>Description</u>                                                                                  |
|------------------|----------------------------------------------------------------------------------------------------|
| **base_env-only**| Configure the base environment (sudo, default directories, wallpapers, LibreOffice color palettes) |
| **packages-only**| Configure standard software repositories and install packages                                      |
| **libvirt-only** | Configure KVM and Libvirt                                                                          |
| **tools-only**   | Install the labmachine tools into /usr/local/bin/                                                  |
| **vbox-only**    | Install VirtualBox extensions                                                                      |

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

# Additional Optional Tools:

Once the machine has been configured as a lab machine, if there are additional disks attached, the `create-and-mount-courses-disk.sh` and `create-and-mount-home-disk.sh` scripts can be used to automatically partition/format and then mount the additional disks on `/install/courses` and `/home` in the case that the additional disk space is needed for the lab environments to be installed and run (i.e. as in when using a standard OS image Azure where you need to add an additional disk to provide more disk space).
