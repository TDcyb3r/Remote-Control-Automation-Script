## Remote Control Automation Script

This project is a Bash-based automation tool that performs anonymous remote reconnaissance through the Tor network.
It installs required tools, activates anonymity with Nipe, connects to a remote machine via SSH, runs WHOIS and Nmap scans on a target of your choice, and downloads all results automatically for local review. 

---

## Overview

The script is designed to simplify remote scanning workflows by:
- Ensuring your connection is anonymized before any recon activity
- Automating remote WHOIS and Nmap scans
- Handling SSH authentication
- Downloading results and saving detailed logs
- Organizing all output in a dedicated folder

This makes the tool ideal for educational use, controlled labs, and secure automation tasks.

---

## Key Features

- Tor-based anonymity using Nipe
- WHOIS lookup on the target (executed on the remote server)
- Nmap port scanning on the target
- SSH automation using sshpass
- Automatic file download to the local machine
- Audit logging for every action performed
- Organized output (WHOIS, Nmap, logs) stored in output/

---

## Output Files

- whois_<target>_<timestamp>.txt – WHOIS results
- nmap_<target>_<timestamp>.txt – Nmap scan results
- audit_log_<timestamp>.txt – Detailed execution log

---

## Execution Flow

	1.	Display banner and initialize environment
	2.	Install required tools (if missing)
	3.	Clone and set up Nipe
	4.	Activate the Tor network and verify anonymity
	5.	Request SSH details and scan target
	6.	Perform WHOIS and Nmap scans on the remote server
	7.	Download all result files locally
	8.	Save all logs for auditing purposes 

---

## Requirements

- Linux OS
- Root privileges
- Internet connection
- Tools: sshpass, nmap, whois, git, curl, perl, Nipe

---

## Legal Notice

This script is intended only for authorized and educational use.
Do not run it on networks or systems you do not own or do not have explicit permission to test.

---

## Author

Tomer Dery





