#!/bin/bash
echo "=== WSL Hadoop Pre-Install Check ==="

echo -n "[1] OS: "
grep -qEi 'ubuntu' /etc/os-release && echo "Ubuntu ✅" || echo "Not Ubuntu ❌"

echo -n "[2] Java: "
java -version &> /dev/null && echo "Installed ✅" || echo "Not Installed ❌"

echo -n "[3] SSH: "
which ssh &> /dev/null && echo "Installed ✅" || echo "Not Installed ❌"

echo -n "[4] pdsh: "
which pdsh &> /dev/null && echo "Installed ✅" || echo "Not Installed ❌"

echo -n "[5] wget: "
which wget &> /dev/null && echo "Installed ✅" || echo "Not Installed ❌"

echo -n "[6] JAVA_HOME: "
[[ -z "$JAVA_HOME" ]] && echo "Not Set ❌" || echo "Set to $JAVA_HOME ✅"

echo -n "[7] Hadoop PATH entries: "
grep -q "HADOOP_HOME" ~/.bashrc && echo "Found ✅" || echo "Not Found ❌"

echo -n "[8] Hadoop Directory: "
[[ -d "$HOME/hadoop" ]] && echo "Found ✅" || echo "Not Found ❌"

echo "=== Done ==="
