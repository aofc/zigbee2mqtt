#!/bin/bash -e

if [ -d data-backup ]; then
   echo "ERROR: Backup directory exists. May be previous restoring was failed?"
   echo "1. Save 'data-backup' and 'data' dirs to safe location to make possibility to restore config later."
   echo "2. Manually delete 'data-backup' dir and try again."
   exit 1
fi

if which systemctl 2> /dev/null > /dev/null; then
       echo "Stopping Zigbee2MQTT..."
       sudo systemctl stop zigbee2mqtt
else
       echo "Skipped stopping Zigbee2MQTT, no systemctl found"
fi

echo "Creating backup of configuration..."
cp -R data data-backup

echo "Removing symbolic link to zigbee-herdsman-converters.aofc..."
rm -f ./node_modules/zigbee-herdsman-converters

echo "Updating..."
git checkout HEAD -- npm-shrinkwrap.json
git pull

echo "Installing dependencies..."
npm ci

echo "Updating zigbee-herdsman-converters..."
mv ./node_modules/zigbee-herdsman-converters ./node_modules/zigbee-herdsman-converters.Koenkk
#git checkout HEAD -- npm-shrinkwrap.json
#rm -rf ./node_modules/zigbee-herdsman-converters
cd ../zigbee-herdsman-converters.aofc/
git pull
cd ../zigbee2mqtt/
ln -s -T /opt/zigbee-herdsman-converters.aofc /opt/zigbee2mqtt/node_modules/zigbee-herdsman-converters

echo "Restore configuration..."
cp -R data-backup/* data
rm -rf data-backup

if which systemctl 2> /dev/null > /dev/null; then
       echo "Starting Zigbee2MQTT..."
       sudo systemctl start zigbee2mqtt
else
       echo "Skipped starting Zigbee2MQTT, no systemctl found"
fi

echo "Done!"
