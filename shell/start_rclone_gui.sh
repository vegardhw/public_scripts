#!/bin/bash
# Script purpose:
# - Stop running rclone GUI
# - Unbind the active port used
# - Start the new rclone GUI session and save the new token
# - Send notifications to a webhook or ntfy

### Edit these variables ###
port=5572  # The port you want to unbind
host="192.168.4.3:5572" # The IP:port of the new rclone GUI session
file_output="/mnt/user/afolder/token.txt"
log_file="/mnt/user/appdata/rclone/rclone_output.log"
webhook_url=""
ntfy_url=""

### Do not change below this line ###

# Function to stop rclone GUI service
stop_rclone_gui() {
    echo "Stopping rclone GUI..."

    # Find the process ID (PID) of the rclone GUI process
    pid=$(pgrep -f "rclone rcd")

    if [ -z "$pid" ]; then
        echo "rclone GUI is not running."
    else
        # Kill the rclone GUI process
        kill "$pid"

        # Confirm the process has been stopped
        if [ $? -eq 0 ]; then
            echo "rclone GUI stopped successfully."
        else
            echo "Failed to stop rclone GUI."
        fi
    fi
}

# Call the function to stop current rclone gui
stop_rclone_gui

# Function to find and kill the process using the specified port
unbind_port() {
    echo "Unbinding port $port..."

    # Find the PID of the process using the specified port
    pid=$(lsof -t -i :"$port")

    if [ -z "$pid" ]; then
        echo "No process found using port $port."
    else
        # Kill the process
        kill "$pid"

        # Confirm the process has been killed
        if [ $? -eq 0 ]; then
            echo "Process using port $port has been stopped successfully."
        else
            echo "Failed to stop the process using port $port."
        fi
    fi
}

# Call the function to unbind active port
unbind_port

# Start rclone gui and log output
rclone rcd --rc-web-gui --rc-addr "$host" &> "$log_file" &

# Give the daemon some time to start
sleep 5s

# Read the initial output from the log file
command_output=$(cat "$log_file")

# Print the captured output (optional)
echo "Command output:"
echo "$command_output"

# Get the last line of the output
last_line=$(echo "$command_output" | tail -n 1)

# Extract the last 38 characters of the last line
trimmed_output=$(echo "$last_line" | awk '{print substr($0, length($0)-37, 38)}')

# Store the trimmed output in a text file
echo "$trimmed_output" > $file_output

# Prepare the payload for the Discord webhook
discord_payload=$(cat <<EOF
{
    "content": "The new rclone gui token is: $trimmed_output"
}
EOF
)

# Send the notification to the Discord webhook
curl -H "Content-Type: application/json" -d "$discord_payload" "$webhook_url"

# Optionally, print the trimmed output to the console
echo "Trimmed output:"
echo "$trimmed_output"

# Send notification to ntfy
curl -d "$trimmed_output" "$ntfy_url"
