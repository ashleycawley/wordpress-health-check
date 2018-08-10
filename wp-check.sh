#!/bin/bash

# A script to health-check and rate the integrity and health of a WordPress website

# Notes - ideas to implement in the future:
# - Show number of installed Plugins
# - Show any files or folders with 777 permissions
# - Check WP version with: php wp-cli.phar core check-update


# Test to see if the user is root (we don't want them to be root)
if [ `whoami` == root ]
then
	echo && echo "DO NOT run this script as root. Please run this script as the user who owns the website." && echo
	exit 1
fi


function CHECKSUMCORE {

DLPATH=/tmp/

# Downloads WP-CLI - http://wp-cli.org/
curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar --output ${DLPATH}wp-cli.phar &>/dev/null

# Checks to see if it is present and shows its version
# php ${DLPATH}wp-cli.phar --info

# Checks the checksums of your WordPress website against what they should be
php ${DLPATH}wp-cli.phar core verify-checksums

# Removes WP-CLI from the system after work is done
rm -f ${DLPATH}wp-cli.phar

}

read -p "Enter the full path of the WordPress site you wish to check: " SITEPATH

cd $SITEPATH

echo && echo "Website selected..."
php ${DLPATH}wp-cli.phar option list --search=siteurl


echo && echo "Comparing the version of this WordPress website with the latest..." && sleep 2
php ${DLPATH}wp-cli.phar core check-update


echo && echo -e "Checking number of installed Plugins... \c"
find ./wp-content/plugins/ -maxdepth 1 -type d | wc -l
echo

echo && echo "Listing active Plugins..."
php ${DLPATH}wp-cli.phar plugin list --status=active

echo && echo "Listing inactive Plugins..."
php ${DLPATH}wp-cli.phar plugin list --status=inactive

echo "Testing the checksums of the WordPress Core files..."
CHECKSUMCORE
