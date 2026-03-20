#bin/bash
# This script is used to deploy the shell script to the target server
# Usage: ./Shell_deployment.sh <target_server_ip> <target_server_user> <target_server_password>
ssh sarah@stapp01
git clone https://3000-port-i5k5ct3pchhjfd4w.labs.kodekloud.com/sarah/web.git /tmp/web
cd /tmp/web
cp -r /tmp/web/* /var/www/html/
rm -rf /tmp/web
