class puppet_openstack_tester::puppet_jobs {

  File {
    notify  => Exec['jenkins_jobs_update'],
    require => Exec['install_jenkins_job_builder'],
  }

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
  }

  file { "/etc/jenkins_jobs/config/openstack_integration_test.yml":
    content =>
'- defaults:
    name: global
    zuul-url: http://127.0.0.1:8001/jenkins_endpoint
- job:
    name : gate-puppet-integration
    project-type: freestyle
    defaults: global
    disabled: false
    concurrent: true
    quiet-period: 0
    block-downstream: false
    block-upstream: false
    builders:
     - shell: |
          #!/bin/bash
          set -x
          set -e
          set -u

          # build the cherry-pick command to get the correct commit
          export ref=`echo $ZUUL_CHANGES | awk -F":" \'{print $3}\'`
          export cherry_pick_command="git fetch https://review.openstack.org/$ZUUL_PROJECT $ref && git cherry-pick FETCH_HEAD"

          # get the name of the directory where we need to change code
          project=`echo $ZUUL_PROJECT | sed -e "s/stackforge\/puppet-//g"`
          export module_repo="modules/${project}"

          mkdir $BUILD_ID
          cd $BUILD_ID
          git clone "https://github.com/bodepd/puppet_openstack_builder"
          cd puppet_openstack_builder
          echo `pwd`
          export checkout_branch_command="${cherry_pick_command:-}"
          source /home/jenkins-slave/heat.sh
          # create stack
          stack_name="puppet_integration_${BUILD_ID}"
          heat stack-create $stack_name -P pre_puppet_commands="cd /etc/puppet/${module_repo} && ${checkout_branch_command}" -f heat_templates/openstack_2_role.yaml
          # call to an external script to block until the stack is complete
          # and then run our test
          ruby test_scripts/wait_until_stack_ready.rb $stack_name
    triggers:
      - zuul
',
  }

}
