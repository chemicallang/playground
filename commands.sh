# delete play-* directories
find /home/playground/app -maxdepth 1 -type d -name "play-*" -exec rm -rf {} +

# upload the executable, please replace YOUR_IP_ADDRESS before doing this
scp playground USERNAME@YOUR_IP_ADDRESS:/home/playground/app/playground.new

# set permissions to uploaded executable
cd /home/playground/app
chown playground:playground playground.new
chmod +x playground.new

# make executable current
mv playground playground.old
mv playground.new playground

# restart the service
sudo systemctl restart playground.service
sudo systemctl status playground.service

# clean current logs
sudo journalctl --rotate           # rotate current logs
sudo journalctl --vacuum-time=1s -u playground.service
# get new logs (last 50)
sudo journalctl -u playground.service -n 50 --no-pager


# Please replace SOME_USER with the actual user name before using this file
cat /etc/systemd/system/playground.service
[Unit]
Description=Playground App
After=network.target docker.service
Requires=docker.service

[Service]
User=SOME_USER
Group=playground
WorkingDirectory=/home/playground/app
Environment=PLAYGROUND_ENV=production
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/usr/local/bin/run-playground.sh
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
UMask=0000

# Ensure Docker and app dir are writable
ReadWritePaths=/home/playground/app /var/run/docker.sock
ProtectHome=no
PrivateTmp=false

[Install]
WantedBy=multi-user.target