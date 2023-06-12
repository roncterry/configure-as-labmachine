# configure-as-labmachine

**TLDR:**

* Perform a default openSUSE Leap or SLES/SLED installation (Use Ext4 rather than Btrfs for the file system with no separate `/home` partition and GNOME instead of KDE for the desktop environment). 

* Download this project onto the installed openSUSE Leap or SLE 15 system.

* Run the `configure-as-labmachine.sh` script (as root or via sudo) to configure that image to be the standard SUSE Training lab machine image. (It is best to switch to a virtual terminal and run the command. It can be run from a terminal in a GUI though some issues might arise due to the user environment being updated .)

* Reboot the machine

**openSUSE Leap versions supported:** Leap 15.1/15.2/15.3/15.4/15.5

**SLES/SLED versions supported:** SLE15 SP1/SP2/SP3

The script is 'idempotent' in that the operations it performs will always have the same outcome. This means the script can be rerun safely without having to worry about it breaking something during additional runs. It also means that future versions can be downloaded and run to "update" the system to the latest configuration of the lab machine image.

**Note:** The standard SUSE Training lab machine image is designed to be used to both develop and run course lab environments as well as to develop other aspects of training such as slides, lecture and lab manuals and recordings for eLearning. The packages installed support all of these activities.

# Modifying the Script's behavior and Output:

**Config File:**

The behavior of the script can be modified by editing the `config/configure-as-labmachine.cfg` file. 

One important modification that will most likely need to be made is to edit the `USER_LIST` variable. The default user listed in the variable is **tux**, however if you log in as a different user you will need to change the name of the default user to the one you use. You can add additional users to be configured in the same manner if desired (this is a space delimited list). 

**CLI Arguments:**

The script can perform many different operations to configure the machine to be a "lab machine" some of which are standard some of which are optional .When running the script you can control what operations are performed by using different arguments. If no arguments are supplied to the script then <u>all standard operations will be performed</u> resulting in a <u>full standard lab machine/course development system</u>. 

If you want a subset of the full standard environment you may specify one of the subset base environments as a CLI argument. Only the operations required to install/configure that subset base environment will be performed.

If any one of the standard operations is supplied as an argument only that operation will be performed. 

Optional operations will only be performed if the arguments are supplied without any of the stadalone standard operations or subset base environments (with the exception of optional-only and base_dev_env-only). Multiple optional operations can be supplied as a space delimited list and each will be performed.

The additional arguments can be supplied with any of the subset base, standalone standard or optional operations.

**Example:**
    `configure-as-labmachine.sh [arg] [arg] ...`

<u>**Subset Base Environments:**</u>

| <u>Argument</u>        | <u>Description</u>                                                                                                                                                                                                                                                                                                            |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **base_env_only**      | Configure only the base environment (sudo, default directories, base repos/patterns/packages)                                                                                                                                                                                                                                 |
| **base_user_env_only** | Configure only the base user environment (sudo, default directories, wallpapers, user environment, base repos/patterns/packages)                                                                                                                                                                                              |
| **base_virt_env_only** | Configure only the base virtualization environment required to run labs (sudo, default directories, wallpapers, user environment, KVM/Libvirt virtualization, remote access, tools)                                                                                                                                           |
| **base_dev_env_only**  | Configure only the base course development environment (sudo, default directories, wallpapers, user environment, base and extra repos/patterns/packages/flatpaks/appimages, LibreOffice config, remote access, tools (optional operations can also be supplied as additional CLI arguments with this subset base environment) |

<u>**Standalone Standard Operations:**</u>

| <u>Argument</u>   | <u>Description</u>                                                                                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **packages_only** | Configure standard software repositories and install packages along with Flatpaks and AppImages (optional operations can also be supplied as additional CLI arguments with this operation) |
| **libvirt_only**  | Configure KVM and Libvirt                                                                                                                                                                  |
| **tools_only**    | Install the labmachine tools into /usr/local/bin/                                                                                                                                          |
| **user_env_only** | Configure the user(s') shell and GNOME environment and install user local copies of the standard GNOME Shell extensions (including into /etc/skel)                                         |
| **custom_only**   | Only run the custom scripts in the hook (include) directory                                                                                                                                |
| **optional_only** | Only optional opperations if they are supplied as additional CLI arguments                                                                                                                 |

<u>**Optional Operations:**</u>

| <u>Argument</u>         | <u>Description</u>                                                                                                              |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **install-virtualbox**  | Install VirtualBox and the VirtualBox extensions (this implies your agreement with the VirtualBox extensions license agreement) |
| **install-atom_editor** | Download and install the Atom editor                                                                                            |
| **install-teams**       | Add Teams repo and install Teams                                                                                                |
| **install-insync**      | Add Insync repo and install Insync                                                                                              |
| **install-zoom**        | Download and install Zoom                                                                                                       |
| **install-edge**        | Add Microsoft Edge repo and install Edge                                                                                        |

<u>**Additional Arguments:**</u>

| <u>Argument</u>    | <u>Description</u>                                                              |
| ------------------ | ------------------------------------------------------------------------------- |
| **nocolor**        | Disables the colorization of the output                                         |
| **no_restart_gui** | Don't restart the display manager when the script finishes                      |
| **stepthrough**    | Pause after each operation and wait for the Enter key to be pressed to continue |

**Software Repositories:**

There are different sets of software repositories that are added depending on whether you install the full base environment or one of the subset base environments.

The following repositories are added in the full and all subset base environments:

* google-chrome

The following additional repositories are added in the full, base virtualization and base development environments:

* Cloud:Tools
* X11:RemoteDesktop:x2go
* Packman

If you would like to add the additional repos, edit the `config/configure-as-labmachine.cfg` file add them to the `ZYPPER_EXTRA_REPO_LIST` variable. There are optional and potentially desirable repos listed and commented out below that variable. These can be uncommented and moved into the `ZYPPER_EXTRA_REPO_LIST` variable as well. If you add any additional repos to that variable, ensuring that the URL is correct for the distro you are installing on.

**Standard RPM Packages to Install:**

The full standard SUSE Training lab machine image is designed to be used to both develop and run course lab environments as well as to develop other aspects of training such as slides, lecture and lab manuals and recordings for eLearning. Because subsets of the full base environment can be installed the default list of packages are broken into separate pattern and packages lists.

Base System:

* ZYPPER_BASE_PATTERN_LIST
* ZYPPER_BASE_PACKAGE_LIST

Virtualization:

* ZYPPER_VIRT_PATTERN_LIST
* ZYPPER_VIRT_PACKAGE_LIST

Remote Access:

* ZYPPER_REMOTE_ACCESS_PACKAGE_LIST

Course Development:

* ZYPPER_DEV_PACKAGE_LIST

If desired you can add additional packages to these lists as long as they are available in the default repositories or the additional repositories listed in ZYPPER_EXTRA_REPO_LIST. It is also possible to install other custom software (this is discussed below).

**Custom RPM Packages to Install:**

If you have additional custom RPM packages you would like installed you have two options: Specify them via URL or pre-download them for local install. 

If you want to reference these packages via URL then you need to add them to the CUSTOM_REMOTE_PACKAGE_LIST (space delimited list). Otherwise you can download the RPM package files and place them in the `rpms` directory. The packages will then be installed with zypper after the standard repos/patterns/packages have been added and installed. (I.e. this is a way you could install the virtualbmc command.) In either of these cases the install will pause and you will need to manually accept packages and accept/ignore any signing warnings/errors to continue. 

Read the `README-custom_rpms_to_install_go_here` file in that directory for suggestions on what packages to add to this directory.

**Flatpaks to Install:**

If you have any Flatpaks you wish to install you may add the  remotes (repositories) where they can be found to the FLATPAK_REMOTES_LIST (space delimited list) and then the Flatpaks you wish to install to the FLATPAK_INSTALL_LIST (space delimited list) and they will be installed. 

**AppImages to Install:**

If you have AppImages you wish to install you can place them in the `appimages` directory. If you want to use the AppImage daemon (appimaged) to automatically install the AppImages you must set ENABLE_APPIMAGED=Y. This will cause the `/Applications` directory to be created, the AppImage files in the `appimages` directory to be copied into the `/Applications` directory and the appimaged service to be enabled for each user in USER_LIST (via `systemctl enable --user`). This in turn will cause the AppImages to be installed for the user when they log in and the service starts. If the AppImage applications' launchers are not shoing up in SHow Applications, run the following command: `systemctl enable --now --user appimaged.service`

If you don't want to use the AppImage daemon to install the AppImages you can optionally download and install AppImageLauncher (from: https://github.com/TheAssassin/AppImageLauncher/releases) and use it to manually install the AppImages. (This RPM can be installed using the Custom RPM Packages to Install feature discussed above if desired.) In this case the AppImage files will not be automatically copied into the filesystem. To install them you will have to double-click on AppImage files in the `appimages` directory after AppImageLauncher is installed.

**Hook Directory for Custom Commands:**

If you have any custom scripts you would like to run as part of the `configure-lab-machine.sh` script you can put them in the `include` directory and if they have the `.sh` filename extension they will be run at the end of the scripts operations.

# Additional Optional Tools:

Once the machine has been configured as a lab machine, if there are additional disks attached, the `create-and-mount-courses-disk.sh` and `create-and-mount-home-disk.sh` scripts can be used to automatically partition/format and then mount the additional disks on `/install/courses` and `/home`. This is useful in the case that the additional disk space is needed for the lab environments to be installed and run (i.e. as in when using a standard OS image Azure where you need to add an additional disk to provide more disk space).
