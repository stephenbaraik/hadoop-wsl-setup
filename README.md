# Hadoop 3.4.0 Installer for WSL (Ubuntu)

This repository installs Hadoop 3.4.0 in a WSL Ubuntu environment with one command.

## 🚀 One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/hadoop-wsl-installer/main/install.sh | bash
```

## ✅ Post-Install

```bash
start-dfs.sh
start-yarn.sh
jps
```

## 🔍 Validate

```bash
bash ~/hadoop/utils/test.sh
```

## 💡 Notes

- Java 11, SSH, wget, and pdsh are auto-installed.
- Environment variables and config files are fully preconfigured.
