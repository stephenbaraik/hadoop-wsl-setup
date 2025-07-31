# Hadoop 3.4.1 on Windows with WSL (Ubuntu) - Robust Setup

This repository provides a straightforward, robust, and pre-configured setup to install and run **Apache Hadoop 3.4.1** on **Windows 10/11** using the **Windows Subsystem for Linux (WSL)**.

The primary goal is to offer a reliable, one-step installation process that works across new terminal sessions. This allows students and developers to focus on learning Hadoop instead of dealing with complex and repetitive environment setup tasks.

---

## 📋 Prerequisites

Before you begin, ensure the following are installed on your Windows machine:

### ✅ Windows Subsystem for Linux (WSL 2)

WSL allows you to run a Linux environment directly on Windows. **WSL 2** is required for optimal performance.

To install WSL, open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

### ✅ Ubuntu from Microsoft Store

This guide uses the latest Ubuntu LTS version. Once WSL is installed, download Ubuntu from the Microsoft Store and complete the initial user setup.

---

## 🚀 One-Step Installation

The installation is fully automated. Follow these steps **inside your WSL Ubuntu terminal**.

### Step 1: Clone This Repository

First, update your package list and install Git if you don't have it:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git
```

Clone this repository into your home directory and navigate into it:

```bash
cd ~
git clone https://github.com/stephenbaraik/hadoop-wsl-setup.git
cd hadoop-wsl-setup
```

### Step 2: Run the Installation Script

Make the script executable and run it:

```bash
chmod +x install_hadoop.sh
./install_hadoop.sh
```

This script performs the following:

- Installs **OpenJDK 11**, SSH, and required dependencies.
- Downloads and unpacks **Hadoop 3.4.1** into `~/hadoop-3.4.1`.
- Copies pre-configured XML files (`core-site.xml`, `hdfs-site.xml`, etc.).
- Sets environment variables (`JAVA_HOME`, `HADOOP_HOME`, `PATH`).
- Ensures variables are automatically loaded in new terminal sessions.
- Formats the HDFS **NameNode**.

### Step 3: Restart Your Terminal

**Important!**  
To activate the environment variables permanently, **close your WSL terminal and open a new one**.

✅ After restarting, your environment is ready. You do **not** need to run `source ~/.bashrc`.

---

## ▶️ How to Use Hadoop

Once your terminal is restarted, you can start and stop Hadoop using the provided helper script.

### Start Hadoop Services

Navigate to the project directory and run:

```bash
cd ~/hadoop-wsl-setup
./run_hadoop.sh start
```

This starts the following daemons:

- HDFS: `NameNode`, `DataNode`
- YARN: `ResourceManager`, `NodeManager`

You can verify they are running using:

```bash
jps
```

### Stop Hadoop Services

To stop the services and free up system resources:

```bash
./run_hadoop.sh stop
```

---

## 🌐 Exploring Hadoop

With services running, use the following web interfaces:

- **HDFS Web UI (NameNode)**: [http://localhost:9870](http://localhost:9870)
- **YARN Web UI (ResourceManager)**: [http://localhost:8088](http://localhost:8088)
- **MapReduce JobHistory UI**: [http://localhost:19888](http://localhost:19888)

---

## 📁 Common HDFS Commands

The environment is pre-configured, so standard `hdfs dfs` commands work out of the box:

```bash
# Create a home directory
hdfs dfs -mkdir -p /user/$USER

# Create a test directory
hdfs dfs -mkdir /user/$USER/test

# List contents
hdfs dfs -ls /user/$USER

# Upload a file to HDFS
hdfs dfs -put README.md /user/$USER/test

# Verify the file
hdfs dfs -ls /user/$USER/test
```

---

## 📦 Repository Structure

```text
README.md           - This installation and usage guide.
install_hadoop.sh   - Script that fully automates the installation.
run_hadoop.sh       - Script to easily start/stop Hadoop services.
config/             - Pre-configured Hadoop XML files:
                      • core-site.xml
                      • hdfs-site.xml
                      • mapred-site.xml
                      • yarn-site.xml
.gitignore          - Ignores logs and local data from Git tracking.
```

---
