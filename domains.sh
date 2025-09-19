#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # Reset color

# Prompt for the domain
read -p " Enter the domain name (example.com): " domain

# Define temporary and final output files based on domain
subs_temp="${domain}_subs_tmp.txt"
alive_temp="${domain}_alive_tmp.txt"
final_output="${domain}.txt"

# Cleanup temporary files on exit
trap 'rm -f "$subs_temp" "$alive_temp"' EXIT

# Enumerate subdomains
echo -ne "${GREEN}[*] Enumerating subdomains with assetfinder...${NC}"
assetfinder --subs-only "$domain" > "$subs_temp"
if [ -s "$subs_temp" ]; then
    echo -e " ${GREEN}Done${NC}"
    echo -e "${GREEN}===== Successfully completed: Subdomain Enumeration =====${NC}"
else
    echo -e " ${RED}No subdomains found.${NC}"
fi

# Check live hosts and get unique live subdomains in one step
echo -ne "${GREEN}[*] Checking live hosts with httprobe...${NC}"
cat "$subs_temp" | httprobe | sort -u > "$alive_temp"
if [ -s "$alive_temp" ]; then
    echo -e " ${GREEN}Done${NC}"
    total_httprobe=$(wc -l < "$alive_temp")
    echo -e "${GREEN}===== Successfully completed: httprobe Live Host Check =====${NC}"
    echo -e "Live subdomains (httprobe): $final_output (${total_httprobe})"
else
    echo -e " ${RED}No live subdomains found by httprobe.${NC}"
fi

# Copy unique live subdomains to final output file
cp "$alive_temp" "$final_output"

# Show final results
echo "[+] Unique live subdomains saved to: $final_output"
cat "$final_output"

echo -e "=============================="
echo -e "${YELLOW}Enumeration complete.${NC}"

