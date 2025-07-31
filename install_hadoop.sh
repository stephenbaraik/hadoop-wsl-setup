#!/bin/bash

# =============================================================================
#  Hadoop 3.4.1 Robust Installation Script for WSL (Ubuntu)
# =============================================================================
#  This script automates the download, installation, and configuration of
#  Apache Hadoop 3.4.1. It is designed to work reliably across new
#  terminal sessions without manual intervention.
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
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper Functions ---
print_info() {
    echo -e "${GREEN}[INFO] ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] ${1}${NC}"
}

# --- Main Installation Logic ---

# 0. Clean up previous installations for a fresh start
if [ -d "${HADOOP_HOME}" ]; then
    print_warning "Previous Hadoop installation found. Cleaning it up before reinstalling."
    rm -rf "${HADOOP_HOME}"
    rm -rf "${HOME}/hadoop_data"
    # Clean up old entries in .bashrc and .profile to prevent duplication
    sed -i '/# --- Hadoop Environment Variables ---/,/# --- End Hadoop Environment Variables ---/d' ~/.bashrc
    sed -i '/# Load .bashrc if it exists/,+2d' ~/.profile
    print_info "Cleanup complete."
fi

# 1. Install Prerequisites
print_info "Updating packages and installing prerequisites (OpenJDK 11, SSH)..."
sudo apt-get update -y > /dev/null
sudo apt-get install -y openjdk-11-jdk ssh rsync > /dev/null
print_info "Prerequisites installed."

# 2. Setup Passwordless SSH
print_info "Configuring passwordless SSH..."
if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    ssh-keygen -t rsa -P '' -f "${HOME}/.ssh/id_rsa" > /dev/null
    cat "${HOME}/.ssh/id_rsa.pub" >> "${HOME}/.ssh/authorized_keys"
    chmod 0600 "${HOME}/.ssh/authorized_keys"
    print_info "New SSH key generated and configured."
else
    print_warning "SSH key already exists. Skipping generation."
fi
sudo service ssh --full-restart > /dev/null

# 3. Download and Extract Hadoop
print_info "Downloading Hadoop ${HADOOP_VERSION}..."
if [ ! -f "/tmp/hadoop-${HADOOP_VERSION}.tar.gz" ]; then
    wget -q -P /tmp "${HADOOP_URL}"
fi
print_info "Extracting Hadoop to ${INSTALL_DIR}..."
tar -xzf "/tmp/hadoop-${HADOOP_VERSION}.tar.gz" -C "${INSTALL_DIR}"
print_info "Hadoop extracted to ${HADOOP_HOME}."

# 4. Set Environment Variables in .bashrc
print_info "Setting up environment variables in ~/.bashrc..."
{
    echo ""
    echo "# --- Hadoop Environment Variables ---"
    echo "export JAVA_HOME=\$(dirname \$(dirname \$(readlink -f \$(which java))))"
    echo "export HADOOP_HOME=${HADOOP_HOME}"
    echo "export HADOOP_CONF_DIR=\${HADOOP_HOME}/etc/hadoop"
    echo "export HADOOP_MAPRED_HOME=\${HADOOP_HOME}"
    echo "export HADOOP_COMMON_HOME=\${HADOOP_HOME}"
    echo "export HADOOP_HDFS_HOME=\${HADOOP_HOME}"
    echo "export YARN_HOME=\${HADOOP_HOME}"
    echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\${HADOOP_HOME}/lib/native"
    echo "export PATH=\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin:\$PATH"
    echo "export HADOOP_OPTS=\"-Djava.library.path=\${HADOOP_HOME}/lib/native\""
    echo "# --- End Hadoop Environment Variables ---"
} >> "${HOME}/.bashrc"
print_info "Environment variables added to ~/.bashrc."

# 5. *** THE ROBUST FIX ***
# Ensure .profile sources .bashrc for login shells (like new WSL terminals)
print_info "Making the environment robust for new terminals..."
if ! grep -q 'if \[ -n "\$BASH_VERSION" \]; then' "${HOME}/.profile"; then
    {
        echo ""
        echo '# Load .bashrc if it exists'
        echo 'if [ -n "$BASH_VERSION" ]; then'
        echo '    if [ -f "$HOME/.bashrc" ]; then'
        echo '        . "$HOME/.bashrc"'
        echo '    fi'
        echo 'fi'
    } >> "${HOME}/.profile"
    print_info "Your ~/.profile has been updated to automatically load the environment."
else
    print_warning "Your ~/.profile is already correctly configured."
fi

# 6. Configure Hadoop
print_info "Copying pre-configured Hadoop XML files..."
cp ./config/*.xml "${HADOOP_CONF_DIR}/"
echo "export JAVA_HOME=\$(dirname \$(dirname \$(readlink -f \$(which java))))" >> "${HADOOP_CONF_DIR}/hadoop-env.sh"
print_info "Configuration files copied successfully."

# 7. Create HDFS Directories and Format NameNode
print_info "Creating HDFS directories..."
mkdir -p "${HOME}/hadoop_data/hdfs/namenode"
mkdir -p "${HOME}/hadoop_data/hdfs/datanode"
print_info "Formatting the HDFS NameNode. This is a one-time setup."
# Temporarily load the environment for the format command
source "${HOME}/.bashrc"
"${HADOOP_HOME}/bin/hdfs" namenode -format -nonInteractive

echo "------------------------------------------------------------"
print_info "Hadoop installation and configuration complete!"
echo ""
echo "✅ Your environment is now set up to work automatically."
echo "   Close this terminal and open a new one."
echo ""
echo "In the new terminal, you can start Hadoop with:"
echo "   ./run_hadoop.sh start"
echo ""
echo "Then, standard Hadoop commands like 'hdfs dfs -ls /' will work."
echo "------------------------------------------------------------"