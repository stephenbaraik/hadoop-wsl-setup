# 🐘 Hadoop WSL Setup

This repository provides a one-click setup for running **Hadoop 3.4.0** on **Ubuntu via WSL (Windows Subsystem for Linux)**. It installs all required dependencies, sets up environment variables, configures Hadoop, and formats the HDFS.

---

## ✅ Features

- WSL2 + Ubuntu compatible
- Installs Java, SSH, pdsh, wget
- Automatically downloads & configures Hadoop 3.4.0
- Adds environment variables to `.bashrc`
- Starts HDFS/YARN with simple commands

---

## 🚀 Quick Install (Recommended)

```bash
git clone https://github.com/stephenbaraik/hadoop-wsl-setup.git
cd hadoop-wsl-setup
bash install.sh
