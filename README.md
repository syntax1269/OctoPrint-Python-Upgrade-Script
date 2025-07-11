# OctoPrint Python Upgrade Script

This script automates the process of upgrading the Python version used by OctoPrint on Raspbian GNU/Linux 10 (Buster) systems. It leverages `pyenv` to manage Python versions, ensuring a clean and isolated environment for OctoPrint.

**Disclaimer:** While this script aims to automate the process, it's crucial to understand the steps involved. Always back up your OctoPrint instance and critical data before running significant system modifications.

## Features

-   **Automated Prerequisite Installation:** Installs necessary build tools and libraries.
-   **`pyenv` Installation and Configuration:** Sets up `pyenv` for managing Python versions.
-   **Python Version Installation:** Installs a specified Python version (defaulting to 3.12.3) using `pyenv`.
-   **OctoPrint Service Management:** Stops and restarts the OctoPrint service.
-   **Virtual Environment Recreation:** Uses `octoprint-venv-tool` to recreate OctoPrint's virtual environment with the new Python version.
-   **Automatic Path Detection:** Attempts to automatically locate OctoPrint's installation directory and virtual environment path.

## Prerequisites

-   A Raspberry Pi running Raspbian GNU/Linux 10 (Buster).
-   An existing OctoPrint installation.
-   Internet connectivity for downloading packages and tools.
-   `sudo` privileges for the user running the script.

## Usage

1.  **Backup OctoPrint:** Before running this script, it is highly recommended to create a full backup of your OctoPrint instance. You can use the OctoPrint Backup & Restore plugin or manually back up your OctoPrint configuration and data.

2.  **Download the Script:**
    If you haven't already, download the `upgrade_octoprint_python.sh` script to your Raspberry Pi.

    ```bash
    # Example: If you're on your Raspberry Pi, you might use wget or curl
    # wget https://raw.githubusercontent.com/syntax1269/OctoPrint-Python-Upgrade-Script/refs/heads/main/upgrade_octoprint_python.sh
    # chmod +x upgrade_octoprint_python.sh
    ```

3.  **Make the Script Executable:**

    ```bash
    chmod +x upgrade_octoprint_python.sh
    ```

4.  **Review and Configure (Optional):**
    Open the `upgrade_octoprint_python.sh` script in a text editor. You can adjust the `PYTHON_VERSION`, `OCTOPI_DEFAULT_INSTALL_DIR`, and `OCTOPI_DEFAULT_VENV_DIR` variables if the automatic detection is not suitable for your setup.

    ```bash
    nano upgrade_octoprint_python.sh
    ```

5.  **Run the Script:**

    ```bash
    ./upgrade_octoprint_python.sh
    ```

    The script will prompt you for your `sudo` password when necessary.

6.  **Source `.bashrc` (if prompted):**
    The script configures your shell for `pyenv`. If the script indicates that `pyenv` configuration was added to `~/.bashrc`, you might need to source it or restart your terminal session for `pyenv` commands to be available in your current shell.

    ```bash
    source ~/.bashrc
    ```

7.  **Verify OctoPrint:**
    After the script completes, access your OctoPrint web interface and verify that it is running correctly and that the Python version has been updated. You can usually find the Python version information in OctoPrint's settings or system information.

## Important Notes

-   **Error Handling:** The script includes basic error handling. If an error occurs, it will log a message and exit. Review the output carefully for any issues.
-   **Manual Intervention:** In some cases, especially if your OctoPrint installation deviates significantly from standard paths, you might need to manually adjust the `OCTOPI_DEFAULT_INSTALL_DIR` and `OCTOPI_DEFAULT_VENV_DIR` variables within the script.
-   **`pyenv` Shell Configuration:** The script attempts to configure `pyenv` for your `bash` shell. If you use a different shell (e.g., `zsh`), you may need to manually add the `pyenv` initialization lines to your shell's configuration file.
-   **WebUI Password Issues:** If you encounter "bad username password" errors after the upgrade, refer to the `Possible Issue: User password invalid for WebUI` section below for troubleshooting steps.

### Possible Issue: User password invalid for WebUI

Once the web interface is loaded and you encounter a bad username password error you will need to run the following command to reset the passoword for the username you are using.


Activate the virtual environment. On OctoPi:
```bash
source ~/oprint/bin/activate
```

Next run the following command to reset the password for the user you are using.
```bash
octoprint user password <user>
# (ex: octoprint user password MyUserName)
```
It will prompt you for a new password and then set it on the user.
Restart OctoPrint for your changes to take effect, using:
```bash
sudo service octoprint restart or similar.
```

# ***Remember to always back up your OctoPrint data before performing major upgrades or system changes.***
