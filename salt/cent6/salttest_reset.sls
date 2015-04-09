{% set bld_user = pillar.get('bld_user','saltadmin') %}
{% set git_blddir =  pillar.get('bld_user_gitbuild','/home/saltadmin/devcode') %}
{% set git_stestdir = pillar.get('bld_user_gitbuild_salttest','/home/saltadmin/devcode/salt-testing') %}
{% set git_stest_rev = pillar.get('git_stest_rev','2014.8.5') %}

## git v1.7 open centos 6 has issues with https, hence cannot get them directly
{% set git_salttest = pillar.get('git_salttest', 'git@github.com:saltstack/salt-testing.git') %}

## this state file expects gitrest to have been processed

clone_salttest:
  cmd.run:
    - name: git clone {{ git_salttest }}
    - cwd: {{ git_blddir }}
    - user: {{ bld_user }}

git_checkout_test_version:
  cmd.run:
    - name: git checkout v{{ git_stest_rev }}
    - cwd: {{ git_stestdir }}
    - user: {{ bld_user }}
    - require:
      - cmd: clone_salttest




