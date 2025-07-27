#!/bin/bash

set -e

echo "[INFO] Updating packages..."
sudo apt update && sudo apt install -y openjdk-11-jdk wget ssh pdsh

echo "[INFO] Downloading Hadoop 3.4.0..."
wget -q https://downloads.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz -P ~
tar -xf ~/hadoop-3.4.0.tar.gz -C ~
rm ~/hadoop-3.4.0.tar.gz
mv ~/hadoop-3.4.0 ~/hadoop

echo "[INFO] Setting up environment variables..."
cat config/.bashrc.append >> ~/.bashrc
cp config/hadoop-profile.sh ~/hadoop/

source ~/.bashrc

echo "[INFO] Configuring Hadoop..."
cp scripts/*.xml ~/hadoop/etc/hadoop/
cp scripts/hadoop-env.sh ~/hadoop/etc/hadoop/

echo "[INFO] Formatting HDFS..."
~/hadoop/bin/hdfs namenode -format

echo "[INFO] Hadoop installation complete!"
echo "Run: start-dfs.sh && start-yarn.sh"
