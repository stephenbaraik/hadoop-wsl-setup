#!/bin/bash

# =============================================================================
#
#          Hadoop Pseudo-Distributed Mode Installer for WSL
#
#   Description: This script automates the installation and configuration of
#                a pseudo-distributed Hadoop instance on WSL.
#   Author:      Gemini
#   Version:     2.0
#
# =============================================================================

set -e # Exit immediately if a command exits with a non-zero status.

# --- Function to print styled messages ---
print_message() {
    local type=$1
    local message=$2
    case "$type" in
        "info")
            echo -e "\\n[\\e[34mINFO\\e[0m] ${message}"
            ;;
        "success")
            echo -e "\\n[\\e[32mSUCCESS\\e[0m] ${message}"
            ;;
        "warning")
            echo -e "\\n[\\e[33mWARNING\\e[0m] ${message}"
            ;;
        "error")
            echo -e "\\n[\\e[31mERROR\\e[0m] ${message}" >&2
            exit 1
            ;;
        *)
            echo "${message}"
            ;;
    esac
}

# --- Check for root privileges ---
check_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        print_message "error" "This script must be run as root. Please use 'sudo'."
    fi
}

# --- Load configuration ---
load_config() {
    if [[ ! -f "hadoop.conf" ]]; then
        print_message "error" "Configuration file 'hadoop.conf' not found."
    fi
    # shellcheck source=hadoop.conf
    source "hadoop.conf"
    print_message "info" "Configuration loaded successfully."
}

# --- Install dependencies ---
install_dependencies() {
    print_message "info" "Updating package lists..."
    apt-get update -y

    print_message "info" "Installing dependencies: OpenJDK ${JAVA_VERSION}, SSH, pdsh..."
    apt-get install -y "openjdk-${JAVA_VERSION}-jdk" openssh-server pdsh
    # Set pdsh to use ssh
    echo "ssh" | update-alternatives --config pdsh
    print_message "success" "Dependencies installed."
}

# --- Create Hadoop user and group ---
create_hadoop_user() {
    print_message "info" "Setting up Hadoop user and group..."
    if ! getent group "${HADOOP_GROUP}" >/dev/null; then
        groupadd "${HADOOP_GROUP}"
        print_message "info" "Group '${HADOOP_GROUP}' created."
    else
        print_message "warning" "Group '${HADOOP_GROUP}' already exists."
    fi

    if ! id -u "${HADOOP_USER}" >/dev/null 2>&1; then
        useradd -m -g "${HADOOP_GROUP}" -s /bin/bash "${HADOOP_USER}"
        print_message "info" "User '${HADOOP_USER}' created."
    else
        print_message "warning" "User '${HADOOP_USER}' already exists."
    fi
}

# --- Setup SSH for Hadoop user ---
setup_ssh() {
    print_message "info" "Configuring SSH for user '${HADOOP_USER}'..."
    local ssh_dir="/home/${HADOOP_USER}/.ssh"
    sudo -u "${HADOOP_USER}" mkdir -p "${ssh_dir}"

    if [[ ! -f "${ssh_dir}/id_rsa" ]]; then
        sudo -u "${HADOOP_USER}" ssh-keygen -t rsa -P '' -f "${ssh_dir}/id_rsa"
        print_message "info" "SSH key generated for '${HADOOP_USER}'."
    else
        print_message "warning" "SSH key already exists for '${HADOOP_USER}'."
    fi

    sudo -u "${HADOOP_USER}" bash -c "cat ${ssh_dir}/id_rsa.pub >> ${ssh_dir}/authorized_keys"
    chmod 600 "${ssh_dir}/authorized_keys"
    chown -R "${HADOOP_USER}:${HADOOP_GROUP}" "${ssh_dir}"

    # Restart SSH service
    service ssh restart
    print_message "success" "SSH configured for passwordless login."
}

# --- Download and extract Hadoop ---
download_hadoop() {
    HADOOP_INSTALL_PATH="${INSTALL_DIR}/hadoop"
    if [[ -d "${HADOOP_INSTALL_PATH}" ]]; then
        print_message "warning" "Hadoop installation directory already exists. Skipping download and extraction."
        return
    fi

    print_message "info" "Downloading Hadoop ${HADOOP_VERSION}..."
    wget -P /tmp "${HADOOP_URL}"

    local hadoop_tarball="/tmp/hadoop-${HADOOP_VERSION}.tar.gz"
    print_message "info" "Extracting Hadoop to ${INSTALL_DIR}..."
    tar -xzf "${hadoop_tarball}" -C "${INSTALL_DIR}"
    mv "${INSTALL_DIR}/hadoop-${HADOOP_VERSION}" "${HADOOP_INSTALL_PATH}"
    rm "${hadoop_tarball}"
    print_message "success" "Hadoop extracted to ${HADOOP_INSTALL_PATH}."
}

# --- Set environment variables ---
setup_environment() {
    print_message "info" "Setting up environment variables..."
    local env_file="/etc/profile.d/hadoop.sh"
    # Discover JAVA_HOME dynamically
    local java_home
    java_home=$(dirname "$(dirname "$(readlink -f "$(which java)")")")

    cat > "${env_file}" <<EOF
export JAVA_HOME=${java_home}
export HADOOP_HOME=${INSTALL_DIR}/hadoop
export HADOOP_INSTALL=\${HADOOP_HOME}
export HADOOP_MAPRED_HOME=\${HADOOP_HOME}
export HADOOP_COMMON_HOME=\${HADOOP_HOME}
export HADOOP_HDFS_HOME=\${HADOOP_HOME}
export YARN_HOME=\${HADOOP_HOME}
export HADOOP_COMMON_LIB_NATIVE_DIR=\${HADOOP_HOME}/lib/native
export PATH=\$PATH:\${HADOOP_HOME}/sbin:\${HADOOP_HOME}/bin
EOF

    chmod +x "${env_file}"
    print_message "success" "Environment variables set in ${env_file}."
    print_message "warning" "Please log out and log back in or run 'source ${env_file}' to apply the new environment variables."
}

# --- Configure Hadoop ---
configure_hadoop() {
    print_message "info" "Configuring Hadoop..."
    local hadoop_conf_dir="${INSTALL_DIR}/hadoop/etc/hadoop"

    # Create data directories
    mkdir -p "${HDFS_DATA_DIR}/namenode"
    mkdir -p "${HDFS_DATA_DIR}/datanode"
    chown -R "${HADOOP_USER}:${HADOOP_GROUP}" "${HDFS_DATA_DIR}"

    # Configure hadoop-env.sh
    # shellcheck source=/etc/profile.d/hadoop.sh
    source /etc/profile.d/hadoop.sh
    echo "export JAVA_HOME=${JAVA_HOME}" >> "${hadoop_conf_dir}/hadoop-env.sh"

    # Configure core-site.xml
    cat > "${hadoop_conf_dir}/core-site.xml" <<EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>${HDFS_NAMENODE_URI}</value>
    </property>
</configuration>
EOF

    # Configure hdfs-site.xml
    cat > "${hadoop_conf_dir}/hdfs-site.xml" <<EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>${HDFS_REPLICATION}</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file://${HDFS_DATA_DIR}/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file://${HDFS_DATA_DIR}/datanode</value>
    </property>
</configuration>
EOF

    # Configure mapred-site.xml
    cat > "${hadoop_conf_dir}/mapred-site.xml" <<EOF
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
EOF

    # Configure yarn-site.xml
    cat > "${hadoop_conf_dir}/yarn-site.xml" <<EOF
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
EOF

    chown -R "${HADOOP_USER}:${HADOOP_GROUP}" "${INSTALL_DIR}/hadoop"
    print_message "success" "Hadoop configuration files updated."
}

# --- Format HDFS NameNode ---
format_namenode() {
    print_message "info" "Formatting HDFS NameNode..."
    sudo -u "${HADOOP_USER}" "${INSTALL_DIR}/hadoop/bin/hdfs" namenode -format -force
    print_message "success" "HDFS NameNode formatted."
}


# --- Main function ---
main() {
    check_root
    load_config
    install_dependencies
    create_hadoop_user
    setup_ssh
    download_hadoop
    setup_environment
    configure_hadoop
    format_namenode

    print_message "success" "Hadoop installation and configuration complete!"
    print_message "info" "To start Hadoop, run the following commands as the '${HADOOP_USER}' user:"
    echo "  ${INSTALL_DIR}/hadoop/sbin/start-dfs.sh"
    echo "  ${INSTALL_DIR}/hadoop/sbin/start-yarn.sh"
    echo
    print_message "info" "To stop Hadoop, run:"
    echo "  ${INSTALL_DIR}/hadoop/sbin/stop-yarn.sh"
    echo "  ${INSTALL_DIR}/hadoop/sbin/stop-dfs.sh"
}

# --- Run the main function ---
main