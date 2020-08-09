#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
YNH_PHP_VERSION="7.3"
pkg_dependencies="php${YNH_PHP_VERSION}-imagick php${YNH_PHP_VERSION} php${YNH_PHP_VERSION}-mbstring php${YNH_PHP_VERSION}-cli php${YNH_PHP_VERSION}-xml php${YNH_PHP_VERSION}-gd"

# =============================================================================
# COMMON ROUNDCUBE FUNCTIONS
# =============================================================================

# Execute a composer command from a given directory
# usage: composer_exec workdir COMMAND [ARG ...]
exec_composer() {
  local workdir=$1
  shift 1

  COMPOSER_HOME="${workdir}/.composer" \
    php "${workdir}/composer.phar" $@ \
      -d "${workdir}" --quiet --no-interaction
}

# Install and initialize Composer in the given directory
# usage: init_composer destdir
init_composer() {
  local destdir=$1

  # install composer
  curl -sS https://getcomposer.org/installer \
    | COMPOSER_HOME="${destdir}/.composer" \
        php -- --quiet --install-dir="$destdir" \
    || ynh_die "Unable to install Composer"

  # install composer.json
  cp "${destdir}/composer.json-dist" "${destdir}/composer.json"

  # update dependencies to create composer.lock
  exec_composer "$destdir" install --no-dev \
    || ynh_die "Unable to update Roundcube core dependencies"
}
