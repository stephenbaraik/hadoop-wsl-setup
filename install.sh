#!/bin/bash
set -e

echo "[INFO] Updating packages..."
sudo apt update && sudo apt install -y openjdk-11-jdk wget ssh pdsh

echo "[INFO] Downloading Hadoop 3.4.0 from Apache..."
wget --timeout=30 --show-progress https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz -P ~

echo "[INFO] Extracting Hadoop..."
tar -xf ~/hadoop-3.4.0.tar.gz -C ~
rm ~/hadoop-3.4.0.tar.gz
mv ~/hadoop-3.4.0 ~/hadoop

echo "[INFO] Setting up environment variables..."
cat ~/hadoop-wsl-installer/config/.bashrc.append >> ~/.bashrc
cp ~/hadoop-wsl-installer/config/hadoop-profile.sh ~/hadoop/
source ~/.bashrc

echo "[INFO] Configuring Hadoop..."
cp ~/hadoop-wsl-installer/scripts/*.xml ~/hadoop/etc/hadoop/
cp ~/hadoop-wsl-installer/scripts/hadoop-env.sh ~/hadoop/etc/hadoop/

echo "[INFO] Formatting HDFS..."
~/hadoop/bin/hdfs namenode -format

echo "[INFO] Hadoop installation complete!"
echo "Run: start-dfs.sh && start-yarn.sh"
