# Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with identity](#setup)
    * [What identity affects](#what-identity-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with identity](#beginning-with-identity)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module manages identities like users and groups.

[![Build Status](https://travis-ci.org/vshn/puppet-identity.svg?branch=master)](https://travis-ci.org/vshn/puppet-identity)
[![vshn-identity](https://img.shields.io/puppetforge/v/vshn/identity.svg)](https://forge.puppetlabs.com/vshn/identity)

## Module Description

It provides some defined types and hiera helpers to mass-manage users and groups.
Some features:

* Define users and groups in hiera
* Cleanly remove users and groups with `ensure => absent`
* Manage `skel` files
* Deliver user specific dotfiles

## Setup

### What identity affects

* Users
* Groups
* `/etc/skel` directory

### Beginning with identity

It's not needed to include or instantiate the main class to use this module.
The main class is just there to pass a hash of users and groups to the `create_resources` function
and to manage the `skel` directory.
The main functionality lies in the defined types (see below).

## Usage

You can pass a hash of users and groups to the main class or call the two
defined types `identity::user` or `identity::group` directly, passing the correct parameters.

Some specialities explained:

* **identity::user::ignore_uid_gid**: Allows to ignore the uid and gid parameters,
  even if they define something. This can be usefull if you normally manage the
  uids and gids, but want to make an exception on some systems.
* **identity::user::manage_home**: Creates or deletes the home directory of the user.
* **identity::user::manage_dotfiles**: If set to true, dofiles from *identity::dotfiles_source/$username* are
  delivered to the users home directory. The files are not purged if they would disapear at the source.
  This parameter also wants the parameter `manage_home` to be true.

### Hiera example

```
---
classes:
  - identity

identity::manage_skel: true
identity::skel_source: 'puppet:///modules/identity_data/skel'
identity::dotfiles_source: 'puppet:///modules/identity_data'

identity::user_defaults:
  ignore_uid_gid: false
  groups:
    - users

identity::users:
  test.user:
    ensure: present
    uid: 2001
    comment: 'Test User'
    password: 'pwhash'
    ssh_keys:
      main:
        key: 'thekey'
    groups:
      - staff
    manage_dotfiles: true
  zwei.user:
    ensure: present
    comment: 'Test User2'
    groups:
      - staff
```

## Reference

All parameters are documented inline. Have a look at the .pp files in `manifests/`.

## Limitations

The module is just tested under Ubuntu 14.04, but it should work on other platforms too.
As the module is using the `purge_ssh_keys` parameter, it's not compatibly with Puppet versions
below 3.6.0.

## Development

1. Fork it ( https://github.com/tobru/puppet-knot/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Make sure your PR passes the Rspec tests.

