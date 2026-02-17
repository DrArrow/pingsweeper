# PingSweeper 🛰️
Native Linux Multi-Protocol Network Sweeper

PingSweeper is a lightweight Bash-based network scanner designed for Linux.
It performs fast host discovery using multiple protocols including ICMP, TCP, UDP, and ARP.

## 🚀 Features

- 🔎 ICMP Ping Sweep
- 🌐 TCP Port-Based Host Discovery
- 📡 UDP Probe Detection
- 🖧 ARP Scan with MAC + Vendor Lookup
- 🎨 Clean Colorized Output
- ⚡ Parallel Background Scanning
- 🐧 Native Linux (no heavy dependencies)

## 📦 Requirements

PingSweeper is built for Linux systems and requires:

- `bash`
- `ping`
- `nc` (netcat)
- `ip` (iproute2 package)
- `/usr/share/ieee-data/oui.txt` (for vendor lookup in ARP mode)

On Debian/Ubuntu:

``` 
sudo apt install netcat iproute2 ieee-data
```


## 📥 Installation

Clone the repository:
```
git clone https://github.com/yourusername/pingsweeper.git
cd pingsweeper
chmod +x ping_sweeper.sh
```


Run it:
```
./ping_sweeper.sh
```

## 🛠 Usage
```
ping_sweeper.sh -p <icmp|tcp|udp|arp> <start-ip> <end-ip>

```

## Examples
 ```
 ICMP sweep
./ping_sweeper.sh -p icmp 192.168.1.1 .254

 TCP sweep (ports 22, 80, 443)
./ping_sweeper.sh -p tcp 192.168.1.1 .254

 UDP sweep (ports 53, 123)
./ping_sweeper.sh -p udp 192.168.1.1 .254

 ARP sweep (requires sudo)
sudo ./ping_sweeper.sh -p arp 192.168.1.1 .254

```

## 🔎 Protocol Modes
## ICMP

Uses standard ping requests to identify live hosts.

## TCP

Attempts connection to common ports:

22 (SSH)

80 (HTTP)

443 (HTTPS)

If any port responds, the host is considered alive.

## UDP
Sends UDP packets to:

53 (DNS)

123 (NTP)

If a response is detected, the host may be alive.

## ARP

Uses neighbor table inspection via ip neigh

Displays:

IP address

MAC address

Vendor (if available)

## 📊 Example Output
```
Protocol: icmp
Range: 192.168.1.1 → 192.168.1.254

[ICMP] Alive: 192.168.1.1
[ICMP] Alive: 192.168.1.10
[ICMP] Alive: 192.168.1.25

Scan completed.
```

## ⚠️ Notes

ARP scanning requires root privileges.

UDP detection is not always reliable due to how UDP works.

Large ranges may spawn many background processes.

Designed for local network enumeration.

## 🧠 How It Works

Converts IP addresses to integers.

Iterates through the range.

Executes protocol-specific checks in parallel.

Waits for all background jobs to complete.

Displays results in real-time.

## 🔐 Legal Disclaimer

This tool is intended for:

Network diagnostics

Lab environments

Authorized security testing

Do not use on networks you do not own or have explicit permission to test.

## 📄 License

MIT License (recommended)