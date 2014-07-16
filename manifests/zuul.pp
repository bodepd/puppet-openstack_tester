class puppet_openstack_tester::zuul {

  class { '::zuul::merger': }
  class { '::zuul::merger': }

  file { '/etc/zuul/layout.yaml':
    ensure => present,
    source => 'puppet:///modules/puppet_openstack_tester/zuul/layout.yaml',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/openstack_functions.py':
    ensure => present,
    source => 'puppet:///modules/puppet_openstack_tester/zuul/openstack_functions.py',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/logging.conf':
    ensure => present,
    source => 'puppet:///modules/puppet_openstack_tester/zuul/logging.conf',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/gearman-logging.conf':
    ensure => present,
    source => 'puppet:///modules/puppet_openstack_tester/zuul/gearman-logging.conf',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/merger-logging.conf':
    ensure => present,
    source => 'puppet:///modules/puppet_openstack_tester/zuul/merger-logging.conf',
  }

  file { '/home/zuul/.ssh':
    ensure  => directory,
    owner   => 'zuul',
    group   => 'zuul',
  }

  # why do I have to add this and they don't perhaps b/c something was wrong with
  # the ssh agent on the image that I created?
  file { '/home/zuul/.ssh/config':
    owner   => 'zuul',
    group   => 'zuul',
    content => "Host review.openstack.org\n  IdentityFile /var/lib/zuul/ssh/id_rsa\n  StrictHostKeyChecking no"
  }

}
