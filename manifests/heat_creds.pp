#
# this class deploys heat credentials as
# required by rackspace cloud (I am not sure
# if this is the same as what is required
# for a regular openstack deployment)
#
class openstack_tester::heat_creds(
  $username,
  $password,
  $local_user,
  $heat_endpoint,
  $keystone_endpoint,
  $tenant_id,
  $tenant                = 'admin',
  $protocol              = 'https',
  $openstack_private_key = '',
) {

  File {
    owner   => $local_user,
    group   => $local_user,
  }

  file { "/home/${local_user}/heat.sh":
    content => template('openstack_tester/heat_creds.sh.erb'),
  }

  if $openstack_private_key != '' {
    ensure_resource( 'file', "/home/${local_user}/.ssh", {'ensure' => 'directory' })
    file { "/home/${local_user}/.ssh/id_rsa":
      content => $openstack_private_key,
      mode    => '0600',
    }
  }

}
