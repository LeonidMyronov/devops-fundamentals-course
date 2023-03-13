#!/bin/bash
# Part 1. Automate the build process with Bash
# Using Vim or Nano editor create a shell script build-client.sh in the scripts folder of project’s lab_1 directory. This script must perform the following operations over the source of this GitHub repository (you will need to clone it):
# Install the app’s npm dependencies.
# Invoke the client app’s build command with the --configuration flag.
# Set and use the ENV_CONFIGURATION (production or empty string for development configuration) env variable to specify the app’s configuration to use during the build.
# When the build is finished script should compress all built content/files in one client-app.zip file in the dist folder.
# Check if the file client-app.zip exists before building. If so, remove it from the file system and proceed with the build.
# Using Vim or Nano editor create a new shell script (quality-check.sh) which will run code quality tools (linting, unit tests, npm audit, etc.) over the client app from the previous step and report if the app has some problems with its quality.
# [Optionally], automate the build and quality processes for this app/repo.
# [Optionally], integrate script, created in Task 1 (for counting the number of files in directories) into the build-client.sh script, to calculate the count of files in the client’s app dist folder after the build and display accordingly.

ROOT_DIR=$(pwd)
ARCHIVE_FILE=client-app.zip

cd ../shop-angular-cloudfront

# load project ENV variables
if [ -f .bashrc ]; then
    echo "loading env vars from .bashrc file ..."
    source .bashrc
fi
if [ -f .zshrc ]; then
    echo "loading env vars from .zshrc file ..."
    source .zshrc
fi
if [ -f .env ]; then
    echo "loading env vars from .env file ..."
    source .env
fi


if [ -d node_modules ]; then
    echo "cleaning node modules folder..."
    rm -fR node_modules/
fi

echo "npm install..."
npm install > /dev/null
echo "npm run build..."

npm run build --configuration=$ENV_CONFIGURATION > /dev/null

if [ -f dist/$ARCHIVE_FILE ]; then
    echo 'removing existing archive...'
    rm -f dist/$ARCHIVE_FILE
fi

echo "calculating files in the app dist folder after the build:"
source $ROOT_DIR/count_files_number dist


echo "zipping dist folder..."
zip -r ./dist/$ARCHIVE_FILE ./dist/* > /dev/null

echo "done."
exit 0