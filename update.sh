#!/bin/bash -e

if [ -d data-backup ]; then
   echo "ERROR: Backup directory exists. May be previous restoring was failed?"
   echo "1. Save 'data-backup' and 'data' dirs to safe location to make possibility to restore config later."
   echo "2. Manually delete 'data-backup' dir and try again."
   exit 1
fi

echo "Stopping Zigbee2MQTT..."
sudo systemctl stop zigbee2mqtt

echo "Creating backup of configuration..."
cp -R data data-backup

echo "Removing symbolic link to zigbee-herdsman-converters.aofc..."
rm -f ./node_modules/zigbee-herdsman-converters

echo "Updating..."
git checkout HEAD -- npm-shrinkwrap.json
git pull
npm update
npm install

echo "Installing dependencies..."
npm ci

echo "Updating zigbee-herdsman-converters..."
#git checkout HEAD -- npm-shrinkwrap.json
#rm -rf ./node_modules/zigbee-herdsman-converters
cd ../zigbee-herdsman-converters.aofc/
git pull
npm ci
cd ../zigbee2mqtt/
mv ./node_modules/zigbee-herdsman-converters ./node_modules/zigbee-herdsman-converters.Koenkk
ln -s -T /opt/zigbee-herdsman-converters.aofc /opt/zigbee2mqtt/node_modules/zigbee-herdsman-converters

echo "Restore configuration..."
cp -R data-backup/* data
rm -rf data-backup
sudo chown -R tv:tv .
sudo chown www-data:www-data htpasswd

echo "Starting Zigbee2MQTT..."
sudo systemctl start zigbee2mqtt

echo "Done!"
