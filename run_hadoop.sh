#!/bin/bash

# =============================================================================
#  Hadoop Start/Stop Script
# =============================================================================
#  A simple helper script to start or stop all Hadoop daemons.
# =============================================================================

# Source environment variables if they aren't set
if [ -z "$HADOOP_HOME" ]; then
    echo "HADOOP_HOME not set. Sourcing ~/.bashrc"
    source ~/.bashrc
fi

# Check if HADOOP_HOME is now set
if [ -z "$HADOOP_HOME" ]; then
    echo "Error: HADOOP_HOME is not set. Please check your ~/.bashrc configuration."
    exit 1
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
