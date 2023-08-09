import os
import subprocess
import re
import sys
import socket
import struct

# Constant for the /etc/hosts file path
ETC_HOSTS_FILE = '/etc/hosts'

def check_root_privileges():
    """Check if the script is running with root privileges."""
    if not os.geteuid() == 0:
        sys.exit("This script needs to be run as root. Please run with sudo or as the root user.")

def prompt_network_range():
    """Prompt the user to enter the network range to scan."""
    while True:
        network_range = input("Enter the network range to scan (e.g., 192.168.1.0/24): ")
        if validate_network_range(network_range):
            return network_range
        else:
            print("Invalid network range. Please try again.")

def validate_network_range(network_range):
    """Validate the network range format."""
    pattern = re.compile(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}$')
    return bool(pattern.match(network_range))

def scan_network_with_nmap(network_range):
    try:
        nmap_result = subprocess.check_output(['nmap', '-sP', network_range])
        return nmap_result.decode('utf-8')
    except subprocess.CalledProcessError as e:
        sys.exit(f"Error executing nmap: {e}")

def scan_network_with_ping(network_range):
    devices = []

    network_address, netmask = network_range.split('/')
    network_address = struct.unpack('!I', socket.inet_aton(network_address))[0]
    num_hosts = 2**(32 - int(netmask)) - 2

    for i in range(num_hosts):
        host_ip = socket.inet_ntoa(struct.pack('!I', network_address + i + 1))

        try:
            # Use subprocess to send ICMP echo requests
            output = subprocess.check_output(['ping', '-c', '1', '-W', '1', host_ip], universal_newlines=True)

            if "1 packets transmitted, 1 received" in output:
                # Perform reverse DNS lookup
                try:
                    hostname = socket.gethostbyaddr(host_ip)[0]
                except socket.herror:
                    hostname = 'N/A'

                devices.append({"ip": host_ip, "hostname": hostname})
        except subprocess.CalledProcessError:
            pass

        # Calculate progress percentage
        progress = (i + 1) * 100 // num_hosts
        sys.stdout.write(f"\rScanning: {progress}% complete")
        sys.stdout.flush()

    sys.stdout.write("\n")
    sys.stdout.flush()

    return devices

def update_hosts_file(ip_addresses, hostnames):
    """Update the /etc/hosts file with discovered systems."""
    for ip, hostname in zip(ip_addresses, hostnames):
        hostname_without_domain = hostname.split('.')[0]
        with open(ETC_HOSTS_FILE, 'r') as hosts_file:
            hosts_content = hosts_file.read()

        existing_entry = re.search(fr'\b{hostname}\b', hosts_content)

        if existing_entry is None:
            with open(ETC_HOSTS_FILE, 'a') as hosts_file:
                hosts_file.write(f'{ip} {hostname} {hostname_without_domain}.local\n')
            print(f'Added {hostname} with IP {ip} and alias {hostname_without_domain}.local to {ETC_HOSTS_FILE}')
        else:
            updated_hosts_content = re.sub(fr'(\b{ip}\s+)(\S+)', fr'\1{hostname} {hostname} {hostname_without_domain}.local', hosts_content)
            with open(ETC_HOSTS_FILE, 'w') as hosts_file:
                hosts_file.write(updated_hosts_content)
            print(f'Updated {hostname} with new IP {ip} and added alias {hostname_without_domain}.local to {ETC_HOSTS_FILE}')

def main():
    check_root_privileges()

    network_range = prompt_network_range()

    while True:
        scanning_method = input("Select the scanning method (nmap/ping): ")
        if scanning_method in ('nmap', 'ping'):
            break
        else:
            print("Invalid scanning method. Please try again.")

    if scanning_method == 'nmap':
        nmap_output = scan_network_with_nmap(network_range)
        ip_addresses = re.findall(r'(?<=\()\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?=\))', nmap_output)
        hostnames = re.findall(r'Nmap scan report for ([^\s]+)', nmap_output)
    else:
        devices = scan_network_with_ping(network_range)
        ip_addresses = [device['ip'] for device in devices]
        hostnames = [device['hostname'] for device in devices]

    update_hosts_file(ip_addresses, hostnames)

if __name__ == '__main__':
    main()