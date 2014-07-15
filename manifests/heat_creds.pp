#
# this class deploys heat credentials as
# required by rackspace cloud (I am not sure
# if this is the same as what is required
# for a regular openstack deployment)
#
class puppet_openstack_tester::heat_creds(
  $filename,
  $username,
  $password,
  $heat_endpoint,
  $keystone_endpoint,
  $tenant_id,
  $tenant                = 'admin',
  $protocol              = 'https',
  $openstack_private_key = '',
) {

  file { $filename:
    content => template('puppet_openstack_tester/heat_creds.sh.erb'),
  }

  if $openstack_private_key != '' {
    ensure_resource( 'file', '/root/.ssh/', {'ensure' => 'directory' })
    file { '/root/.ssh/id_rsa':
      content => $openstack_private_key,
      mode    => '0600',
    }
  }

}
