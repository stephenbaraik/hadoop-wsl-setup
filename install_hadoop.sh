#!/bin/bash

# =============================================================================
#  Hadoop 3.4.1 Installation Script for WSL (Ubuntu)
# =============================================================================
#  This script automates the download, installation, and configuration of
#  Apache Hadoop 3.4.1 in a pseudo-distributed mode on WSL.
# =============================================================================

# --- Configuration ---
HADOOP_VERSION="3.4.1"
HADOOP_URL="https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
INSTALL_DIR="${HOME}"
HADOOP_HOME="${INSTALL_DIR}/hadoop-${HADOOP_VERSION}"
HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"

# --- Colors for Output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Helper Functions ---
print_info() {
    echo -e "${GREEN}[INFO] ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] ${1}${NC}"
}

# --- Main Installation Logic ---

# 1. Update and Install Prerequisites
print_info "Updating package lists and installing prerequisites (OpenJDK 11, SSH)..."
sudo apt-get update -y
sudo apt-get install -y openjdk-11-jdk ssh rsync
print_info "Prerequisites installed successfully."

# 2. Setup Passwordless SSH
print_info "Setting up passwordless SSH..."
if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    ssh-keygen -t rsa -P '' -f "${HOME}/.ssh/id_rsa"
    cat "${HOME}/.ssh/id_rsa.pub" >> "${HOME}/.ssh/authorized_keys"
    chmod 0600 "${HOME}/.ssh/authorized_keys"
    print_info "Passwordless SSH configured."
else
    print_warning "SSH key already exists. Skipping generation."
fi
# Ensure SSH service is running
sudo service ssh --full-restart

# 3. Download and Extract Hadoop
print_info "Downloading Hadoop ${HADOOP_VERSION}..."
if [ ! -f "/tmp/hadoop-${HADOOP_VERSION}.tar.gz" ]; then
    wget -P /tmp "${HADOOP_URL}"
else
    print_warning "Hadoop archive already exists in /tmp. Skipping download."
fi

print_info "Extracting Hadoop to ${INSTALL_DIR}..."
tar -xzf "/tmp/hadoop-${HADOOP_VERSION}.tar.gz" -C "${INSTALL_DIR}"
print_info "Hadoop extracted to ${HADOOP_HOME}."

# 4. Set Environment Variables
print_info "Setting up environment variables in .bashrc..."
{
    echo ""
    echo "# --- Hadoop Environment Variables ---"
    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))"
    echo "export HADOOP_HOME=${HADOOP_HOME}"
    echo "export HADOOP_INSTALL=\${HADOOP_HOME}"
    echo "export HADOOP_MAPRED_HOME=\${HADOOP_HOME}"
    echo "export HADOOP_COMMON_HOME=\${HADOOP_HOME}"
    echo "export HADOOP_HDFS_HOME=\${HADOOP_HOME}"
    echo "export YARN_HOME=\${HADOOP_HOME}"
    echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\${HADOOP_HOME}/lib/native"
    echo "export PATH=\$PATH:\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin"
    echo "export HADOOP_OPTS=\"-Djava.library.path=\${HADOOP_HOME}/lib/native\""
    echo "# --- End Hadoop Environment Variables ---"
} >> "${HOME}/.bashrc"

print_info "Environment variables added to ~/.bashrc."
print_warning "Please source your .bashrc or restart your terminal to apply changes."
print_warning "Run: source ~/.bashrc"

# Temporarily set for the current session to continue the script
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export HADOOP_HOME=${HADOOP_HOME}
export PATH=$PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

# 5. Copy Pre-configured Files
print_info "Copying pre-configured Hadoop files..."
cp -r ./config/* "${HADOOP_CONF_DIR}/"
# Set JAVA_HOME in hadoop-env.sh
sed -i "s|# export JAVA_HOME=.*|export JAVA_HOME=${JAVA_HOME}|" "${HADOOP_CONF_DIR}/hadoop-env.sh"
print_info "Configuration files copied successfully."

# 6. Create HDFS Directories
print_info "Creating HDFS directories for NameNode and DataNode..."
mkdir -p "${HOME}/hadoop_data/hdfs/namenode"
mkdir -p "${HOME}/hadoop_data/hdfs/datanode"
print_info "HDFS directories created."

# 7. Format the HDFS NameNode
print_info "Formatting the HDFS NameNode. This should only be done once."
"${HADOOP_HOME}/bin/hdfs" namenode -format

print_info "Hadoop installation and configuration complete!"
echo "------------------------------------------------------------"
echo "To start Hadoop, run: ./run_hadoop.sh start"
echo "Then, you can access the web UIs:"
echo "  - HDFS NameNode: http://localhost:9870"
echo "  - YARN ResourceManager: http://localhost:8088"
echo "------------------------------------------------------------"

