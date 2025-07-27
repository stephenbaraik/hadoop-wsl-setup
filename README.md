# Hadoop 3.4.1 on Windows with WSL (Ubuntu)

This repository provides a straightforward, pre-configured setup to install and run Apache Hadoop 3.4.1 on Windows 10/11 using the Windows Subsystem for Linux (WSL) with the Ubuntu distribution.

The goal is to provide a simple, one-step installation process so that students can focus on learning Hadoop rather than getting stuck on complex setup procedures.

## Prerequisites

Before you begin, ensure you have the following installed on your Windows machine:

1.  **Windows Subsystem for Linux (WSL) 2:** WSL allows you to run a Linux environment directly on Windows. WSL 2 is recommended for better performance.
    * To install WSL, open PowerShell as Administrator and run:
        ```bash
        wsl --install
        ```
    * If you already have WSL 1, you can upgrade to WSL 2.

2.  **Ubuntu from the Microsoft Store:** This guide uses the latest Ubuntu LTS version available from the Microsoft Store. Once WSL is installed, get Ubuntu from the store and set up your username and password.

3.  **Java Development Kit (JDK) 8 or 11:** Hadoop runs on the JVM and requires a compatible JDK. We will use OpenJDK 11. The installation script will handle this for you.

## How to Install

The installation is designed to be as simple as possible. Follow these steps inside your **WSL Ubuntu terminal**.

### Step 1: Clone This Repository

Open your Ubuntu terminal. First, update your package lists:

```bash
sudo apt update && sudo apt upgrade -y
```

Install `git` if you don't have it:

```bash
sudo apt install -y git
```

Now, clone this repository into your home directory:

```bash
cd ~
git clone https://github.com/stephenbaraik/hadoop-wsl-setup.git
cd hadoop-on-wsl
```

### Step 2: Run the Installation Script

The repository includes a script that will automate the entire setup process. Make the script executable and then run it:

```bash
chmod +x install_hadoop.sh
./install_hadoop.sh
```

This script will perform the following actions:
* Install OpenJDK 11.
* Download Hadoop 3.4.1.
* Unpack Hadoop into a designated directory (`~/hadoop-3.4.1`).
* Set up necessary environment variables (`JAVA_HOME`, `HADOOP_HOME`, etc.) in your `.bashrc` file.
* Copy the pre-configured Hadoop XML files (`core-site.xml`, `hdfs-site.xml`, etc.) into the correct location.
* Format the HDFS NameNode.

### Step 3: Start Hadoop Services

Once the installation is complete, you can start the Hadoop Distributed File System (HDFS) and Yet Another Resource Negotiator (YARN) services using the provided helper script.

To start all services:
```bash
./run_hadoop.sh start
```

This will start the NameNode, DataNode, ResourceManager, and NodeManager daemons. You can check if they are running using the `jps` command. You should see output similar to this:
```
XXXXX NameNode
XXXXX DataNode
XXXXX ResourceManager
XXXXX NodeManager
XXXXX Jps
```

### Step 4: Stop Hadoop Services

When you are finished with your session, you can stop all the Hadoop services:

```bash
./run_hadoop.sh stop
```

## Exploring Hadoop

Once the services are running, you can interact with Hadoop:

* **HDFS Web UI (NameNode):** [http://localhost:9870](http://localhost:9870)
* **YARN Web UI (ResourceManager):** [http://localhost:8088](http://localhost:8088)

You can use HDFS commands to create directories and move data:

```bash
# Create a directory for your user
hdfs dfs -mkdir -p /user/$USER

# Create a test directory
hdfs dfs -mkdir /user/$USER/test

# List the contents of the directory
hdfs dfs -ls /user/$USER
```

## Repository Structure

* `README.md`: This installation guide.
* `install_hadoop.sh`: The main installation script.
* `run_hadoop.sh`: A helper script to start/stop Hadoop services.
* `config/`: A directory containing the pre-configured Hadoop XML files.
    * `core-site.xml`
    * `hdfs-site.xml`
    * `mapred-site.xml`
    * `yarn-site.xml`
    * `hadoop-env.sh`
* `.gitignore`: To exclude unnecessary files from Git tracking.
