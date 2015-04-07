{% set bld_user = pillar.get('bld_user','saltadmin') %}
{% set rpm_blddir =  pillar.get('bld_user_rpmbuild','/home/saltadmin/rpmbuild') %}
{% set git_blddir =  pillar.get('bld_user_gitbuild','/home/saltadmin/devcode') %}
{% set git_ssedir = pillar.get('bld_user_gitbuild_sse','/home/saltadmin/devcode/sse') %}
{% set git_rev = pillar.get('git_rev','3.1.5') %}

## git v1.7 open centos 6 has issues with https, hence cannot get them directly
{% set git_opensource = pillar.get('git_opensource', 'git@github.com:saltstack/salt.git') %}
{% set git_upstream = pillar.get('git_upstream', 'git@github.com:SS-priv/sse.git') %}

include:
  - cent6

create_sdist:
  cmd.run:
    - name: python setup.py sdist
    - cwd: {{  git_ssedir }}
    - user: {{ bld_user }}
    - require:
      - cmd: git_checkout_version

update_rpmbuild_with_sdist:
  file.copy:
    - name: {{ rpm_blddir }}/SOURCES/salt-{{ git_rev }}.tar.gz
    - source: {{ git_ssedir }}/dist/salt-{{ git_rev }}.tar.gz

# in 2015.2 this wion;t be needed since file.copy will take a user
ensure_correct_user_rpmbuild_sdist:
  cmd.run:
    - name: chown {{ bld_user }}:{{ bld_user }} salt-{{ git_rev }}.tar.gz
    - cwd: {{ rpm_blddir }}/SOURCES
    - user: root

