# Hadoop 3.4.1 on Windows with WSL (Ubuntu) - Robust Setup

This repository provides a straightforward, **robust**, and pre-configured setup to install and run Apache Hadoop 3.4.1 on Windows 10/11 using the Windows Subsystem for Linux (WSL).

The primary goal is to provide a reliable, one-step installation process that **works automatically across new terminal sessions**. This allows students and developers to focus on learning Hadoop rather than getting stuck on complex and repetitive environment setup procedures.

---

## ✅ Prerequisites

Before you begin, ensure you have the following installed on your Windows machine:

1. **Windows Subsystem for Linux (WSL) 2**  
   WSL allows you to run a Linux environment directly on Windows. WSL 2 is required for optimal performance.

   To install WSL, open **PowerShell as Administrator** and run:

   ```powershell
   wsl --install
Ubuntu from the Microsoft Store
This guide uses the latest Ubuntu LTS version. Once WSL is installed, install Ubuntu from the Microsoft Store and complete the initial setup.

🚀 One-Step Installation
The installation is fully automated and should be performed inside your WSL Ubuntu terminal.

Step 1: Clone This Repository
First, update your packages and install Git (if you don't have it already):

bash
Copy
Edit
sudo apt update && sudo apt upgrade -y
sudo apt install -y git
Now, clone this repository and navigate into it:

bash
Copy
Edit
cd ~
git clone https://github.com/stephenbaraik/hadoop-wsl-setup.git
cd hadoop-wsl-setup
Step 2: Run the Installation Script
Make the install script executable and run it:

bash
Copy
Edit
chmod +x install_hadoop.sh
./install_hadoop.sh
This script will:

Install OpenJDK 11, SSH, and other dependencies

Download and unpack Hadoop 3.4.1 into ~/hadoop-3.4.1

Copy pre-configured XML files (core-site.xml, hdfs-site.xml, etc.)

Set up environment variables (JAVA_HOME, HADOOP_HOME, etc.)

Configure shell to auto-load the variables in all future sessions

Format the HDFS NameNode

Step 3: Restart Your Terminal
IMPORTANT: You must close your current WSL terminal and open a new one for environment variables to apply.

After this, your setup is complete and persistent across sessions.

▶️ How to Use Hadoop
Once you've reopened your terminal, you can manage Hadoop with the helper script.

Start Hadoop Services
bash
Copy
Edit
cd ~/hadoop-wsl-setup
./run_hadoop.sh start
This starts:

HDFS: NameNode and DataNode

YARN: ResourceManager and NodeManager

You can verify by running:

bash
Copy
Edit
jps
Stop Hadoop Services
bash
Copy
Edit
./run_hadoop.sh stop
🌐 Web Interfaces
HDFS Web UI (NameNode): http://localhost:9870

YARN Web UI (ResourceManager): http://localhost:8088

MapReduce JobHistory UI: http://localhost:19888

📂 Common HDFS Commands
Here are a few examples to get started with HDFS:

bash
Copy
Edit
# Create a home directory for your user
hdfs dfs -mkdir -p /user/$USER

# Create a test folder
hdfs dfs -mkdir /user/$USER/test

# List contents
hdfs dfs -ls /user/$USER

# Upload a file to HDFS
hdfs dfs -put README.md /user/$USER/test

# Verify the upload
hdfs dfs -ls /user/$USER/test
📁 Repository Structure
File/Folder	Description
README.md	This installation and usage guide
install_hadoop.sh	Robust installation script for Hadoop setup
run_hadoop.sh	Helper script to start/stop Hadoop services
config/	Contains pre-configured Hadoop XML files
.gitignore	Excludes local logs/data from Git tracking

🙌 Support
If you encounter any issues, please check your terminal logs for errors or submit an issue in the GitHub repository.

Happy Hadooping! 🎉

vbnet
Copy
Edit

Let me know if you'd like the same in a downloadable `.md` file!