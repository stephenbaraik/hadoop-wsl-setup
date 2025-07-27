#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 💡 If Hadoop folder exists, skip download/extract
if [ -d "$HOME/hadoop" ]; then
    echo "[INFO] Detected existing ~/hadoop folder. Skipping download and extraction."
else
    echo "[INFO] Updating packages..."
    sudo apt update && sudo apt install -y openjdk-11-jdk wget ssh pdsh

    echo "[INFO] Downloading Hadoop 3.4.0..."
    wget --timeout=30 --show-progress https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz -P ~

    echo "[INFO] Extracting Hadoop..."
    tar -xf ~/hadoop-3.4.0.tar.gz -C ~
    rm ~/hadoop-3.4.0.tar.gz
    mv ~/hadoop-3.4.0 ~/hadoop
fi

echo "[INFO] Setting up environment variables..."
cat "$REPO_DIR/config/.bashrc.append" >> ~/.bashrc
cp "$REPO_DIR/config/hadoop-profile.sh" ~/hadoop/

echo "[INFO] Configuring Hadoop..."
cp "$REPO_DIR/scripts/"*.xml ~/hadoop/etc/hadoop/
cp "$REPO_DIR/scripts/hadoop-env.sh" ~/hadoop/etc/hadoop/

echo "[INFO] Reloading bash config..."
source ~/.bashrc

echo "[INFO] Formatting HDFS..."
~/hadoop/bin/hdfs namenode -format

echo "[✅] Hadoop installation complete!"
echo "👉 Run: start-dfs.sh && start-yarn.sh"
