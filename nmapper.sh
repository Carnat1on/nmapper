#!/bin/bash
clear
file="result.txt"
tmpfile="tmp.txt"
range=()
hosts=()
menuItems=()
# Function to handle cleanup operations
cleanup() {
    echo "Exiting script..."
    # Perform cleanup operations here
    rm "$file"  # Remove the named pipe
    rm "$tmpfile"
    exit 1
}

# Trap the Ctrl+C signal and call the cleanup function
trap cleanup SIGINT


result=$(nmap -sn 192.168.0.0/24 192.168.1.0/24 192.168.50.0/24 192.168.100.0/24 192.168.101.0/24 192.168.102.0/24 -oG $file)
tail -n +2 "$file" | head -n -1 > "$tmpfile"
while IFS= read -r line; do
    
    ip=$(echo "Line: $line" | cut -d':' -f3 | cut -d' ' -f2)
    hosts+=("$ip")
    # Process each line here
done < "$tmpfile"
menu() {
    for ((i=0; i<${#hosts[@]}; i++)); do
        if [[ -n "${hosts[i]}" ]]; then
            menuItems+=("$((i+1)): ${hosts[i]}")
        fi
    done
    for item in "${menuItems[@]}"; do
        echo "$item"
    done
    choice
}
choice() {
    read -p "select ip: " range
    if [[ $range -ge 1 && $range -le ${#hosts[@]} ]]; then
        selected_item="${hosts[$((range-1))]}"
        echo "You selected: $selected_item"
        #nmap $selected_item
    else
        clear
        echo "Invalid choice. Please enter a valid number."
        unset menuItems
        menu
    fi
}
menu

while true; do
        
     # Display actions menu for the chosen drive
    echo "Selected : $selected_item"
    echo "1. View details"
    echo "2. Scan"
    echo "3. Brute scan"
    echo "4. Back to menu"
    echo "5. Exit"

    read -p "Choose an action (1-5): " choice

    case $choice in
        1)
            nmap  -O $selected_item
            echo "Press any key to return"
            read -n 1 -s -r -p ""
            ;;
        2)
            nmap -Pn -v -O $selected_item
            echo "Press any key to return"
            read -n 1 -s -r -p ""
            ;;
        3)
            # Add your custom action here
            nmap -A --script vuln $selected_item
            echo "Press any key to return"
            read -n 1 -s -r -p ""
            ;;
        4)
            ./nmapper.sh
            exit 0
            ;;
        5)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
done



cleanup
