#!/bin/bash

echo "=== WSL Hadoop Pre-Install Check ==="

# Check OS
echo -n "[1] OS: "
grep -qEi 'ubuntu' /etc/os-release && echo "Ubuntu ✅" || echo "Not Ubuntu ❌"

# Check Java
echo -n "[2] Java: "
java -version &> /dev/null && echo "Installed ✅" || echo "Not Installed ❌"

# Check SSH
echo -n "[3] SSH: "
which ssh &> /dev/null && echo "Installed ✅" || echo "Not Installed ❌"

# Check pdsh
echo -n "[4] pdsh: "
which pdsh &> /dev/null && echo "Installed ✅" || echo "Not Installed ❌"

# Check wget
echo -n "[5] wget: "
which wget &> /dev/null && echo "Installed ✅" || echo "Not Installed ❌"

# Check JAVA_HOME
echo -n "[6] JAVA_HOME: "
[[ -z "$JAVA_HOME" ]] && echo "Not Set ❌" || echo "Set to $JAVA_HOME ✅"

# Check ~/.bashrc has Hadoop PATH entries
echo -n "[7] Hadoop PATH entries: "
grep -q "HADOOP_HOME" ~/.bashrc && echo "Found ✅" || echo "Not Found ❌"

# Check Hadoop folder
echo -n "[8] Hadoop Directory: "
[[ -d "$HOME/hadoop" ]] && echo "Found ✅" || echo "Not Found ❌"

echo "=== Done ==="
