# configure-as-labmachine

**TLDR:**

  * Perform a default openSUSE Leap or SLES/SLED installation (Use Ext4 rather than Btrfs for the file system with no separate `/home` partition and GNOME instead of KDE for the desktop environment). 

  * Download this project onto the installed openSUSE Leap or SLE 15 system.

  * Run the `configure-as-labmachine.sh` script (as root or via sudo) to configure that image to be the standard SUSE Training lab machine image. (It is best to switch to a virtual terminal and run the command. It can be run from a terminal in a GUI though some issues might arise due to the user environment being updated .)

* Reboot the machine

**openSUSE Leap versions supported:** Leap 15.1/15.2/15.3/15.4

**SLES/SLED versions supported:** SLE15 SP1/SP2/SP3

The script is 'idempotent' in that the operations it performs will always have the same outcome. This means the script can be rerun safely without having to worry about it breaking something durring additional runs. It also means that future versions can be downloaded and run to "update" the system to the latest configuration of the lab machine image.

**Note:** The standard SUSE Training lab machine image is designed to be used to both develop and run course lab environments as well as to develop other aspects of training such as slides, lecture and lab manuals and recordings for eLearning. The packages installed support all of these activities.



# Modifying the Script's behavior and Output:

**Config File:**

The behavior of the script can be modified by editing the `config/configure-as-labmachine.cfg` file. 

One important modification that will most likely need to be made is to edit the `USER_LIST` variable. The default user listed in the variable is **tux**, however if you log in as a different user you will need to change the name of the default user to the one you use. You can add additional users to be configured in the same manner if desired (this is a space delimited list). 

**CLI Arguments:**

The script can perform many different operations to configure the machine to be a "lab machine", some of which are standard some of which are optional.

When running the script you can control what operations are performed by using different arguments. If no arguments are supplied to the command then all standard operations will be performed. If any one of the standard operation is supplied as an argument only that operation will be performed. Optional operations will only be performed if the argument is supplied on an additional run of the script. Multiple optional operations can be supplied as a space delimited list and each will be performed.

**Example:**
    `configure-as-labmachine.sh [arg] [arg] ...`

<u>**Standard Operations:**</u>

|<u>Argument</u>    |<u>Description</u>                                                                                                                                 |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| **base_env-only** | Configure the base environment (sudo, default directories, wallpapers, LibreOffice color palettes)                                                |
| **packages-only** | Configure standard software repositories and install packages                                                                                     |
| **libvirt-only**  | Configure KVM and Libvirt                                                                                                                         |
| **tools-only**    | Install the labmachine tools into /usr/local/bin/                                                                                                 |
| **user_env-only** | Configure the user(s') shell and GNOME environment and install user local copies of the standard GNOME Shell extensions (including into /etc/skel)|

<u>**Optional Operations:**</u>

|<u>Argument</u>    |<u>Description</u>                 |
|-------------------|-----------------------------------|
| **install-virtualbox** | Install VirtualBox and the VirtualBox extensions  |
| **install-atom_editor** | Download and install the Atom editor  |
| **install-teams** | Add Teams repo and install Teams  |
| **install-insync**| Add Insync repo and install Insync|
| **install-zoom**  | Download and install Zoom         |

<u>**Additional Arguments:**</u>

|<u>Argument</u>    |<u>Description</u>                 |
|-------------------|-----------------------------------|
| **stepthrough**  | Pause after each operation and wait for the Enter key to be pressed to continue         |


**Software Repositories:**

**Note**:  This automatically adds the following software repositories:

  * google-chrome
  * Cloud:Tools
  * X11:RemoteDesktop:x2go

If you would like to add the **packman** repo, edit the `config/configure-as-labmachine.cfg` file then uncomment and move the packman repo into the `ZYPPER_REPOS_LIST` variable. There are other optional and potentially desirable repos commented out as well listed below that variable. These can be uncommented and moved into the `ZYPPER_REPOS_LIST` variable in the same manner. You may add any additional repos to that variable as well (ensuring that the URL is correct for the distro).

**Standard RPM Packages to Install:**

The standard SUSE Training lab machine image is designed to be used to both develop and run course lab environments as well as to develop other aspects of training such as slides, lecture and lab manuals and recordings for eLearning. The default list of packages in ZYPPER_PACKAGE_LIST support all of these activities.

If desired you can add additional packages to this list as long as they are available in the default repositories or the additional repositories listed in ZYPPER_REPO_LIST. It is also possible to install other custom software (this is discussed below).

**Custom RPM Packages to Install:**

If you have additional custom RPM packages you would like installed you have two options: Specify and install them via URL or pre-download them for local install. 

If you want to reference these packages via URL then you need to add them to the CUSTOM_REMOTE_PACKAGE_LIST (space delimited list). Otherwise you can download the RPM package files and place them in the `rpms` directory. The packages will then be installed with zypper after the standard repos/patterns/packages have been added and installed. (I.e. this is a way you could install the virtualbmc command.) In either of these cases the install will pause and you will need to manually accept packages and accept/ignore any signing warnings/errors to continue. 

Read the `README-custom_rpms_to_install_go_here` file in that directory for suggestions on what packages to add to this directory.

**Flatpaks to Install:**

If you have any Flatpaks you wish to install you may add the  remotes (repositories) where they can be found to the FLATPAK_REMOTES_LIST (space delimited list) and then the Flatpaks you wish to install to the FLATPAK_INSTALL_LIST (space delimited list) and they will be installed. 

**AppImages to Install:**

If you have AppImages you wish to install you can place them in the `appimages` directory. If you want to use the AppImage daemon (appimaged) to automatically install the AppImages you must set ENABLE_APPIMAGED=Y. This will cause the `/Applications` directory to be created, the AppImage files in the `appimages` directory to be copied into the `/Applications` directory and the appimaged service to be enabled for each user in USER_LIST (via `systemctl enable --user`). This in turn will cause the AppImages to be installed for the user when they log in and the service starts. 

If you don't want to use the AppImage daemon to install the AppImages you can optionally download and install AppImageLauncher (from: https://github.com/TheAssassin/AppImageLauncher/releases) and use it to manually install the AppImages. (This RPM can be installed using the Custom RPM Packages to Install feature discussed above if desired.) In this case the AppImage files will not be automatically copied into the filesystem. To install them you will have to double-click on AppImage files in the `appimages` directory after AppImageLauncher is installed.

**Hook Directory for Custom Commands:**

If you have any custom scripts you would like to run as part of the `configure-lab-machine`. sh script you can put them in the `include` directory and if they have the `.sh` filename extension they will be run at the end of the scripts operations.

# Additional Optional Tools:

Once the machine has been configured as a lab machine, if there are additional disks attached, the `create-and-mount-courses-disk.sh` and `create-and-mount-home-disk.sh` scripts can be used to automatically partition/format and then mount the additional disks on `/install/courses` and `/home`. This is useful in the case that the additional disk space is needed for the lab environments to be installed and run (i.e. as in when using a standard OS image Azure where you need to add an additional disk to provide more disk space).
