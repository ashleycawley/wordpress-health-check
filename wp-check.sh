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

DLPATH=/tmp/

function CHECKSUMCORE {

# Checks the checksums of your WordPress website against what they should be
php ${DLPATH}wp-cli.phar core verify-checksums

}

function PAUSEANDPROMPT {

echo && read -p "Press [Enter] to proceed..." && echo

}

if [ -f wp-config.php ]
	then

SITEPATH=(`pwd`)

else

read -p "Enter the full path of the WordPress site you wish to check: " SITEPATH

fi

cd $SITEPATH

# Downloads WP-CLI - http://wp-cli.org/
curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar --output ${DLPATH}wp-cli.phar &>/dev/null

echo && echo "Website selected..."
php ${DLPATH}wp-cli.phar option list --search=siteurl


echo && echo "Comparing the version of this WordPress website with the latest..." && sleep 2
php ${DLPATH}wp-cli.phar core check-update
PAUSEANDPROMPT

echo && echo -e "Checking number of installed Plugins and their status... \c"
php ${DLPATH}wp-cli.phar plugin status
PAUSEANDPROMPT

echo && echo -e "Checking installed Themes and their status... \c"
php ${DLPATH}wp-cli.phar theme status
PAUSEANDPROMPT

# echo && echo "Listing active Plugins..."
# php ${DLPATH}wp-cli.phar plugin list --status=active
# PAUSEANDPROMPT

# echo && echo "Listing inactive Plugins..."
# php ${DLPATH}wp-cli.phar plugin list --status=inactive
# PAUSEANDPROMPT

echo "Testing the checksums of the WordPress Core files..."
CHECKSUMCORE
PAUSEANDPROMPT

echo "Listing Administrators..."
php ${DLPATH}wp-cli.phar user list --role=administrator
PAUSEANDPROMPT

exit 0
