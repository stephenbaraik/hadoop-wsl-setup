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
cat ~/hadoop-wsl-setup/config/.bashrc.append >> ~/.bashrc
cp ~/hadoop-wsl-setup/config/hadoop-profile.sh ~/hadoop/
source ~/.bashrc

echo "[INFO] Configuring Hadoop..."
cp ~/hadoop-wsl-setup/scripts/*.xml ~/hadoop/etc/hadoop/
cp ~/hadoop-wsl-setup/scripts/hadoop-env.sh ~/hadoop/etc/hadoop/

echo "[INFO] Formatting HDFS..."
~/hadoop/bin/hdfs namenode -format

echo "[INFO] Hadoop installation complete!"
echo "Run: start-hdfs.sh && start-yarn.sh"
