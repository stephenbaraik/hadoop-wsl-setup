#!/bin/bash

# =============================================================================
#  Hadoop Start/Stop Script
# =============================================================================
#  A simple helper script to start or stop all Hadoop daemons.
#  This script is designed to be robust and not rely on pre-set
#  environment variables in the current shell.
# =============================================================================

# --- Define Hadoop Home directly to avoid environment issues ---
HADOOP_VERSION="3.4.1"
export HADOOP_HOME="${HOME}/hadoop-${HADOOP_VERSION}"

# --- Helper Functions ---
print_error() {
    echo -e "\033[0;31m[ERROR] ${1}\033[0m"
}

# --- Pre-run Check ---
# Verify the Hadoop directory exists before proceeding.
if [ ! -d "$HADOOP_HOME" ]; then
    print_error "Hadoop directory not found at ${HADOOP_HOME}"
    print_error "Please ensure you have run the install_hadoop.sh script successfully."
    exit 1
fi

# Source the hadoop-env.sh to get necessary configurations
if [ -f "$HADOOP_HOME/etc/hadoop/hadoop-env.sh" ]; then
    source "$HADOOP_HOME/etc/hadoop/hadoop-env.sh"
fi

start_hadoop() {
    echo "Starting HDFS (NameNode and DataNode)..."
    "$HADOOP_HOME/sbin/start-dfs.sh"
    echo "Starting YARN (ResourceManager and NodeManager)..."
    "$HADOOP_HOME/sbin/start-yarn.sh"
    echo "Hadoop services started. Use 'jps' to check running daemons."
}

stop_hadoop() {
    echo "Stopping YARN (ResourceManager and NodeManager)..."
    "$HADOOP_HOME/sbin/stop-yarn.sh"
    echo "Stopping HDFS (NameNode and DataNode)..."
    "$HADOOP_HOME/sbin/stop-dfs.sh"
    echo "Hadoop services stopped."
}

# --- Script Logic ---
case "$1" in
    start)
        start_hadoop
        ;;
    stop)
        stop_hadoop
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac

exit 0
