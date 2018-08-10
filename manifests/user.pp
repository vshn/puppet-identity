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
# [*membership*]
#   Default: minimum. See https://puppet.com/docs/puppet/5.5/type.html#user-attribute-membership
#
# [*home*]
#   Default: /home/$username. See https://docs.puppetlabs.com/references/latest/type.html#user-attribute-home
#
# [*home_perms_recursive*]
#   Default: false. Manage home folder permissions recursively.
#
# [*home_perms*]
#   Default: 0755. Home folder permissions
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
# [*manage_group*]
#   Default: true. When true, then a group will be created with the same name as the user. If false
#   the group will not be created and gid has to be set.
#
# [*emptypassword_policy*]
#   Default: false. When true, a user with an empty password will have a `*`
#   set as password instead of a `!`. This is especially handy if you want to
#   disable UsePAM for SSH. `!` is a locked account and without UsePAM the user
#   can't login anymore with key-based authentication.
#
define identity::user (
  Enum['present', 'absent'] $ensure = present,
  String $comment = '',
  Optional[Variant[Integer, String]] $uid = undef,
  Optional[Variant[Integer, String]] $gid = undef,
  Array[String] $groups = [],
  Optional[String] $password = undef,
  Hash[Any, Any] $ssh_keys = {},
  Boolean $purge_ssh_keys = true,
  Boolean $manage_home = true,
  Optional[Enum['minimum', 'inclusive']] $membership = 'minimum',
  Optional[String] $home = undef,
  Boolean $home_perms_recursive = false,
  String $home_perms = '0755',
  Boolean $system = false,
  String $shell = '/bin/bash',
  Boolean $ignore_uid_gid = false,
  Boolean $manage_dotfiles = false,
  Boolean $manage_group = true,
  Boolean $emptypassword_policy = false,
) {

  include ::identity

  # Input validation

  # Check if gid is set when manage_group is false
  unless $manage_group {
    unless $gid {
      fail('If group is not managed, the gid has to be set')
    }
  }

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
    $_gid = $gid ? {
      undef   => $uid,
      default => $gid,
    }
  }

  # Define the resources
  if $manage_group {
    group { $username:
      ensure => $ensure,
      gid    => $_gid,
      system => $system,
    }
  }

  # Handle passwords and empty password policy
  #
  # When given an empty password Puppet's user resource sets the entry in the
  # password database to "!". By convention an account whose password is
  # prefixed with the exclamation mark ("!") is locked/disabled.
  #
  # When the SSH daemon is configured to not use PAM ("UsePAM no"), login is
  # not permitted for locked accounts even when using key-based authentication.
  # With PAM SSH key-based login attempts skip PAM's authentication phase,
  # making locked accounts accessible.
  #
  # Setting the password in the database to "*" circumvents the issue. No
  # password hash will result in "*" and at the same time the password is not
  # prefixed by "!". SSH without PAM will allow logins to these accounts.
  #
  if $password {
    $_password = $password
  } elsif $emptypassword_policy {
    $_password = '*'
  } else {
    $_password = '!'
  }

  user { $username:
    ensure         => $ensure,
    uid            => $_uid,
    gid            => $_gid,
    groups         => $groups,
    shell          => $shell,
    comment        => $comment,
    managehome     => $manage_home,
    membership     => $membership,
    home           => $home_dir,
    password       => $_password,
    purge_ssh_keys => $purge_ssh_keys,
    system         => $system,
  }

  # ensure resource ordering and proper cleanup
  case $ensure {
    'absent': {
      if ($manage_home) and ($ssh_keys) {
        $ssh_key_defaults = {
          ensure => absent,
          user   => $username,
          'type' => 'ssh-rsa',
          before => User[$username],
        }
        create_resources('ssh_authorized_key',prefix($ssh_keys,"${name}-"),$ssh_key_defaults)
      }
      if $manage_group {
        User[$username] -> Group[$username]
      }

      $_procps_pkg = downcase($::osfamily) ? {
        'redhat' => 'procps-ng',
        default  => 'procps',
      }

      ensure_packages([$_procps_pkg])

      exec { "crontab-remove-${username}":
        onlyif  => "/usr/bin/crontab -u '${username}' -l",
        command => "/usr/bin/crontab -u '${username}' -r",
      } ->
      User[$username]

      exec { "pkill-user-${username}":
        require => [
          Package[$_procps_pkg],

          # Crontab must be disabled first to avoid a race condition
          Exec["crontab-remove-${username}"],
          ],

        # procps would support numeric UIDs, but they are sometimes reused with
        # different usernames.
        onlyif  => "/usr/bin/pgrep --uid '${username}'",
        command => "/bin/bash -x -c '
          for ((i=0; i < 3; ++i)); do
            /usr/bin/pkill --uid \"${username}\" || break
            sleep 1
          done

          if /usr/bin/pgrep --uid \"${username}\"; then
            /usr/bin/pkill --signal KILL --uid \"${username}\"
          fi
        '",
      } ->
      User[$username]
    }
    'present': {
      if $manage_group {
        Group[$username] -> User[$username]
      }
      if $ssh_keys {
        $ssh_key_defaults = {
          ensure => present,
          user   => $username,
          'type' => 'ssh-rsa'
        }
        create_resources('ssh_authorized_key',prefix($ssh_keys,"${name}-"),$ssh_key_defaults)
      }
      if $manage_home {
        $dotfiles_source = $manage_dotfiles ? {
          true    => "${::identity::dotfiles_source}/${username}",
          default => undef,
        }
        if $manage_group {
          $_group = $_gid
        } else {
          $_group = $username
        }
        file { $home_dir:
          ensure  => directory,
          source  => $dotfiles_source,
          recurse => $home_perms_recursive,
          owner   => $username,
          group   => $_group,
          mode    => $home_perms,
        }
      }
    }
    default: {
      fail('The $ensure parameter must be \'absent\' or \'present\'')
    }
  }

}
