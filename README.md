# Hadoop WSL Setup

This script automates the setup of a pseudo-distributed Hadoop instance on Windows Subsystem for Linux (WSL).

## Features

-   **Configurable:** All important parameters like Hadoop version, Java version, and installation directories are in a separate configuration file.
-   **Robust:** The script includes error handling and checks if it's run with the necessary permissions.
-   **Idempotent:** You can run the script multiple times without causing issues. It will skip steps that are already completed.
-   **User Management:** Creates a dedicated `hadoop` user and group for better security and resource management.

## Prerequisites

-   A WSL distribution (e.g., Ubuntu) installed on your Windows machine.
-   Internet connection to download packages.

## How to Use

1.  **Customize the Configuration:**

    Open the `hadoop.conf` file and adjust the variables to your liking. You can change the Hadoop version, installation directory, and other settings.

2.  **Make the Script Executable:**

    Open a WSL terminal and run the following command:
    ```bash
    chmod +x install-hadoop-on-wsl.sh
    ```

3.  **Run the Script:**

    You need to run the script with `sudo` because it installs packages and modifies system files.
    ```bash
    sudo ./install-hadoop-on-wsl.sh
    ```
    The script will prompt you for any necessary input.

## What the Script Does

1.  **Reads Configuration:** Loads the settings from `hadoop.conf`.
2.  **Checks Prerequisites:** Verifies that it is run with `sudo`.
3.  **Installs Dependencies:** Installs Java, SSH, and other required packages.
4.  **Creates Hadoop User:** Creates a `hadoop` user and group.
5.  **Sets up SSH:** Configures passwordless SSH for the `hadoop` user.
6.  **Downloads and Extracts Hadoop:** Downloads the specified version of Hadoop and extracts it to the installation directory.
7.  **Sets Environment Variables:** Configures system-wide environment variables for Hadoop and Java.
8.  **Configures Hadoop:** Sets up the Hadoop configuration files (`core-site.xml`, `hdfs-site.xml`, etc.) based on the settings in `hadoop.conf`.
9.  **Formats HDFS NameNode:** Initializes the HDFS file system.

After the script finishes, you will have a working pseudo-distributed Hadoop instance on your WSL.