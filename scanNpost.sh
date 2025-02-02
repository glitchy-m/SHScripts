# --- Retrieve Local IP Address ---
# This command attempts to find the first non-loopback IPv4 address.
# Adjust the parsing if your environment’s ifconfig output differs.
local_ip=$(ifconfig | awk '/inet / && $2 != "127.0.0.1" { print $2; exit }')

# --- Retrieve Public (External) IP Address ---
# Using an external service to get your public IP address.
public_ip=$(curl -s https://ifconfig.me)

# --- Create JSON Payload ---
# We build a JSON string containing both IP addresses.
json_data=$(printf '{"local_ip": "%s", "public_ip": "%s"}' "$local_ip" "$public_ip")

# --- Send the Data via POST ---
# The -H flag sets the content type to JSON.
curl -X POST -H "Content-Type: application/json" -d "$json_data" https://dlogging-554433.firebaseio.com/data_log.json

# Optionally, print a message or the response from the server.
echo "Data sent:"
echo "$json_data"
