class puppet_openstack_tester::puppet_jobs {

  file { '/etc/jenkins_jobs/config/openstack_unit_test.yml':
    content =>
"
- job-template:
    name: 'puppet-{repo}-{puppet_version}-unit'
    project-type: freestyle
    defaults: global
    disabled: false
    concurrent: true
    quiet-period: 0
    block-downstream: false
    block-upstream: false
    builders:
      - shell: |
          apt-get install -y ruby-bundler
          export PUPPET_GEM_VERSION='~> {puppet_version}'
          bundle install
          bundle exec rake spec SPEC_OPTS='--format documentation'
- job-group:
    name: 'puppet-module-unit'
    puppet_version:
      - 2.7
      - 3.6
    repo:
      - glance
      - keystone
      - cinder
      - nova
      - horizon
      - openstack
      - swift
    jobs:
      - 'puppet-{repo}-{puppet_version}-unit'
- project:
    name: puppet-module-unit
    jobs:
      - puppet-module-unit
",
    notify  => Exec['jenkins_jobs_update'],
    require => Exec['install_jenkins_job_builder'],
  }

#  file { "/etc/jenkins_jobs/config/openstack_test.yml":
#    content =>
#'- defaults:
#    name: global
#    zuul-url: http://127.0.0.1:8001/jenkins_endpoint
#- job:
#    name : gate-puppet-dev-env
#    project-type: freestyle
#    defaults: global
#    disabled: false
#    concurrent: true
#    quiet-period: 0
#    block-downstream: false
#    block-upstream: false
#    builders:
#      - shell: |
#          #!/bin/bash
#          set -x
#          set -e
#          set -u
#
#          export module_install_method="librarian"
#          export operatingsystem="ubuntu"
#          export openstack_version="grizzly"
#          export test_mode="puppet_openstack"
#          export ref=`echo $ZUUL_CHANGES | awk -F":" \'{print $3}\'`
#          export cherry_pick_command="git fetch https://review.openstack.org/$ZUUL_PROJECT $ref && git cherry-pick FETCH_HEAD"
#
#          # get the name of the directory where we need to change code
#          project=`echo $ZUUL_PROJECT | sed -e "s/stackforge\/puppet-//g"`
#          export module_repo="modules/${project}"
#
#          mkdir $BUILD_ID
#          cd $BUILD_ID
#          git clone "git://github.com/stackforge/puppet-openstack_dev_env"
#          cd puppet-openstack_dev_env
#          echo `pwd`
#          export checkout_branch_command="${cherry_pick_command:-}"
#
#          bash -xe test_scripts/openstack_test.sh
#    triggers:
#      - zuul
#',
#    notify  => Exec['jenkins_jobs_update'],
#    require => Exec['install_jenkins_job_builder', 'reload_account_config'],
#  }
#
}
