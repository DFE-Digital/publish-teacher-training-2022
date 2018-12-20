#!/bin/bash
# ----------------------
# KUDU Deployment Script
# Version: 1.0.17
# ----------------------
# Helpers
# -------
exitWithMessageOnError () {
  if [ ! $? -eq 0 ]; then
    echo "An error has occurred during web site deployment."
    echo $1
    exit 1
  fi
}
# Prerequisites
# -------------
# Verify node.js installed
hash node 2>/dev/null
exitWithMessageOnError "Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment."
# Setup
# -----
SCRIPT_DIR="${BASH_SOURCE[0]%\\*}"
SCRIPT_DIR="${SCRIPT_DIR%/*}"
ARTIFACTS=$SCRIPT_DIR/../artifacts
KUDU_SYNC_CMD=${KUDU_SYNC_CMD//\"}
if [[ ! -n "$DEPLOYMENT_SOURCE" ]]; then
  DEPLOYMENT_SOURCE=$SCRIPT_DIR
fi
if [[ ! -n "$NEXT_MANIFEST_PATH" ]]; then
  NEXT_MANIFEST_PATH=$ARTIFACTS/manifest
  if [[ ! -n "$PREVIOUS_MANIFEST_PATH" ]]; then
    PREVIOUS_MANIFEST_PATH=$NEXT_MANIFEST_PATH
  fi
fi
if [[ ! -n "$DEPLOYMENT_TARGET" ]]; then
  DEPLOYMENT_TARGET=$ARTIFACTS/wwwroot
else
  KUDU_SERVICE=true
fi
if [[ ! -n "$KUDU_SYNC_CMD" ]]; then
  # Install kudu sync
  echo Installing Kudu Sync
  npm install kudusync -g --silent
  exitWithMessageOnError "npm failed"
  if [[ ! -n "$KUDU_SERVICE" ]]; then
    # In case we are running locally this is the correct location of kuduSync
    KUDU_SYNC_CMD=kuduSync
  else
    # In case we are running on kudu service this is the correct location of kuduSync
    KUDU_SYNC_CMD=$APPDATA/npm/node_modules/kuduSync/bin/kuduSync
  fi
fi
# Rails Helpers
# -----------
setLatestRubyVersion(){
    LATEST_RUBY_VERSION=$(ls /usr/local/.rbenv/versions | grep -v - | grep 2.3 | tail -n 1)
    echo "Using ruby version $LATEST_RUBY_VERSION"
}
initializeDeploymentConfig() {
    if [ -z $BUNDLE_WITHOUT ]; then
        echo "Bundle install with no 'without' options";
        RUBY_OPTIONS="";
    else
        RUBY_OPTIONS="--without $BUNDLE_WITHOUT";
        echo "Bundle install with options $RUBY_OPTIONS";
    fi

    if [ -z $BUNDLE_INSTALL_LOCATION ]; then
        echo "Defaulting gem installation directory to /tmp/bundle";
        BUNDLE_INSTALL_LOCATION="/tmp/bundle";
    else
        echo "Gem installation directory is $BUNDLE_INSTALL_LOCATION";
    fi

    if [ -z $RUBY_SITE_CONFIG_DIR ]; then
        echo "Defaulting site config directory to /home/site/config";
        RUBY_SITE_CONFIG_DIR="/home/site/config"
    else
        echo "site config directory is $RUBY_SITE_CONFIG_DIR";
    fi

    setLatestRubyVersion
}
##################################################################################################################################
# Deployment
# ----------
echo Ruby on Rails deployment.
# 1. KuduSync
if [[ "$IN_PLACE_DEPLOYMENT" -ne "1" ]]; then
  "$KUDU_SYNC_CMD" -v 50 -f "$DEPLOYMENT_SOURCE" -t "$DEPLOYMENT_TARGET" -n "$NEXT_MANIFEST_PATH" -p "$PREVIOUS_MANIFEST_PATH" -i ".git;.hg;.deployment;deploy.sh"
  exitWithMessageOnError "Kudu Sync failed"
fi
initializeDeploymentConfig
echo "$DEPLOYMENT_TARGET"
if [ -e "$DEPLOYMENT_TARGET/Gemfile" ]; then
  echo "Found gemfile"
  pushd "$DEPLOYMENT_TARGET"

  eval "$(rbenv init -)"
  exitWithMessageOnError "init failed"

  echo "Setting ruby version"
  rbenv global $LATEST_RUBY_VERSION
  exitWithMessageOnError "Failed to switch ruby versions"

  echo "Running bundle clean"
  bundle clean --force

  echo "Running bundle install"
  mkdir -p $BUNDLE_INSTALL_LOCATION
  bundle config --global path $BUNDLE_INSTALL_LOCATION
  bundle install --no-deployment $RUBY_OPTIONS
  exitWithMessageOnError "bundler failed"

  echo "Zipping up bundle contents"
  tar -zcf /tmp/gems.tgz -C $BUNDLE_INSTALL_LOCATION .
  exitWithMessageOnError "Error compressing gems"

  mkdir -p $RUBY_SITE_CONFIG_DIR
  exitWithMessageOnError "Error making config directory"

  mv -f /tmp/gems.tgz $RUBY_SITE_CONFIG_DIR

  if [ "$ASSETS_PRECOMPILE" == true ]; then
    echo "running rake assets:precompile"
    bundle exec rake --trace assets:precompile
  fi
  exitWithMessageOnError "precompilation failed"
  popd
fi
##################################################################################################################################
echo "Finished successfully."
