{% set bld_user = pillar.get('bld_user','saltadmin') %}
{% set rpm_blddir =  pillar.get('bld_user_rpmbuild','/home/saltadmin/rpmbuild') %}
{% set git_stestdir = pillar.get('bld_user_gitbuild_salttest','/home/saltadmin/devcode/salt-testing') %}

{% set git_stest_rev = pillar.get('git_stest_rev','2014.8.5') %}

create_test_sdist:
  cmd.run:
    - name: python setup.py sdist
    - cwd: {{  git_stestdir }}
    - user: {{ bld_user }}

update_rpmbuild_with_test_sdist:
  file.copy:
    - name: {{ rpm_blddir }}/SOURCES/SaltTesting-{{ git_stest_rev }}.tar.gz
    - source: {{ git_stestdir }}/dist/SaltTesting-{{ git_stest_rev }}.tar.gz

# in 2015.2 this won't be needed since file.copy will take a user
ensure_correct_user_rpmbuild_test_sdist:
  cmd.run:
    - name: chown {{ bld_user }}:{{ bld_user }} SaltTesting-{{ git_stest_rev }}.tar.gz
    - cwd: {{ rpm_blddir }}/SOURCES
    - user: root
    - template: jinja
    - require:
      - file: update_rpmbuild_with_test_sdist

