# == Defined Type: user
#
# Manages a user and his primary group
#
# === Parameters
#
# [*ensure*]
#   Default: present
#
# [*comment*]
#   Default: ''. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-comment
#
# [*uid*]
#   Default: undef. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-uid
#
# [*gid*]
#   Default: $uid. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-gid
#
# [*groups*]
#   Default: []. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-groups
#
# [*password*]
#   Default: undef. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-password
#
# [*ssh_keys*]
#   Default: {}. A hash of SSH public keys which are assiciated with this user account.
#   The hash is passed to the create_resources function to create `ssh_authorized_key` resources.
#
# [*purge_ssh_keys*]
#   Default: true. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-purge_ssh_keys
#
# [*manage_home*]
#   Default: true. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-managehome
#   It also removes the homedirectory if the parameter ensure is set to absent.
#
# [*home*]
#   Default: /home/$username. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-home
#
# [*system*]
#   Default: false. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-system
#
# [*shell*]
#   Default: /bin/bash. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-shell
#
# [*ignore_uid_gid*]
#   Default: false. If set to true, the uid and gid parameters are ignored and always set to undef.
#
# [*manage_dotfiles*]
#   Default: false. When true, then deliver some dotfiles found in identity::dotfiles_source/$username
#   to the users home directory. They won't be purged if they are not there.
#
define identity::user (
  $ensure          = present,
  $comment         = '',
  $uid             = undef,
  $gid             = $uid,
  $groups          = [],
  $password        = undef,
  $ssh_keys        = {},
  $purge_ssh_keys  = true,
  $manage_home     = true,
  $home            = undef,
  $system          = false,
  $shell           = '/bin/bash',
  $ignore_uid_gid  = false,
  $manage_dotfiles = false,
) {

  # Input validation
  validate_string($comment)
  validate_array($groups)
  validate_hash($ssh_keys)
  validate_bool($purge_ssh_keys)
  validate_bool($manage_home)
  validate_bool($system)
  validate_absolute_path($shell)
  validate_bool($ignore_uid_gid)
  validate_bool($manage_dotfiles)

  # Variable collection
  $username = $title
  $home_dir = $home ? {
    undef   => "/home/${username}",
    default => $home,
  }

  # ignore $uid and $gid, even if they are passed
  if $ignore_uid_gid {
    $_uid = undef
    $_gid = undef
  } else {
    $_uid = $uid
    $_gid = $gid
  }

  # Define the resources
  group { $username:
    ensure => $ensure,
    gid    => $_gid,
    system => $system,
  }
  user { $username:
    ensure         => $ensure,
    uid            => $_uid,
    gid            => $_gid,
    groups         => $groups,
    shell          => $shell,
    comment        => $comment,
    managehome     => $manage_home,
    home           => $home_dir,
    password       => $password,
    purge_ssh_keys => $purge_ssh_keys,
    system         => $system,
  }

  # ensure resource ordering and proper cleanup
  case $ensure {
    'absent': {
      if $manage_home {
        # TODO more validation needed
        exec { "rm -rf ${home_dir}":
          path   => [ '/bin', '/usr/bin' ],
          onlyif => "test -d ${home_dir}",
        }
      }
      User[$username] -> Group[$username]
    }
    'present': {
      Group[$username] -> User[$username]
      if $ssh_keys {
        $ssh_key_defaults = {
          ensure => present,
          user   => $username,
          'type' => 'ssh-rsa'
        }
        create_resources('ssh_authorized_key', $ssh_keys, $ssh_key_defaults)
      }
      if ($manage_dotfiles and $manage_home) {
        file { $home_dir:
          ensure       => directory,
          source       => "${::identity::dotfiles_source}/${username}",
          recurse      => remote,
          recurselimit => 1,
          owner        => $username,
          group        => $username,
          mode         => '0600',
        }
      }
    }
    default: {
      fail('The $ensure parameter must be \'absent\' or \'present\'')
    }
  }

}
