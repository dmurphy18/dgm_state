{% set bld_user = pillar.get('bld_user','saltadmin') %}
{% set rpm_blddir =  pillar.get('bld_user_rpmbuild','/home/saltadmin/rpmbuild') %}
{% set git_ssedir = pillar.get('bld_user_gitbuild_sse','/home/saltadmin/devcode/sse') %}
{% set git_rev = pillar.get('git_rev','3.1.5') %}
{% set git_stest_rev = pillar.get('git_stest_rev','2014.8.5') %}

{% set curr_date = None | strftime("%a %b %d %Y") %}

create_sdist:
  cmd.run:
    - name: python setup.py sdist
    - cwd: {{  git_ssedir }}
    - user: {{ bld_user }}

update_rpmbuild_with_sdist:
  file.copy:
    - name: {{ rpm_blddir }}/SOURCES/salt-{{ git_rev }}.tar.gz
    - source: {{ git_ssedir }}/dist/salt-{{ git_rev }}.tar.gz

# in 2015.2 this won't be needed since file.copy will take a user
ensure_correct_user_rpmbuild_sdist:
  cmd.run:
    - name: chown {{ bld_user }}:{{ bld_user }} salt-{{ git_rev }}.tar.gz
    - cwd: {{ rpm_blddir }}/SOURCES
    - user: root

update_rpmbuild_with_salt_master:
  file.copy:
    - name: {{ rpm_blddir }}/SOURCES/salt-master
    - source: {{ git_ssedir }}/pkg/rpm/salt-master

update_rpmbuild_with_salt_minion:
  file.copy:
    - name: {{ rpm_blddir }}/SOURCES/salt-minion
    - source: {{ git_ssedir }}/pkg/rpm/salt-minion

update_rpmbuild_with_salt_syndic:
  file.copy:
    - name: {{ rpm_blddir }}/SOURCES/salt-syndic
    - source: {{ git_ssedir }}/pkg/rpm/salt-syndic

# in 2015.2 this won't be needed since file.copy will take a user
ensure_correct_user_with_salt_files:
  cmd.run:
    - name: chown {{ bld_user }}:{{ bld_user }} salt-*
    - cwd: {{ rpm_blddir }}/SOURCES
    - user: root

update_rpmbuild_with_spec:
  file.copy:
    - name: {{ rpm_blddir }}/SPECS/salt-sse.spec
    - source: /home/{{ bld_user }}/salt-sse-el6.spec

# in 2015.2 this won't be needed since file.copy will take a user
ensure_correct_user_rpmbuild_spec:
  cmd.run:
    - name: chown {{ bld_user }}:{{ bld_user }} {{ rpm_blddir }}/SPECS/salt-sse.spec
    - cwd: {{ rpm_blddir }}/SPECS
    - user: root

update_spec_testing:
  file.replace:
    - name: {{ rpm_blddir }}/SPECS/salt-sse.spec
    - pattern: |
        _salttesting_ver .*
    - repl: |
        _salttesting_ver {{ git_stest_rev }}
    - count: 1
    - flags:
      - DOTALL
      - MULTILINE
    - bufsize: file

update_spec_version:
  file.replace:
    - name: {{ rpm_blddir }}/SPECS/salt-sse.spec
    - pattern: |
        ^Version: .*
    - repl: |
        Version: {{ git_rev }}
    - count: 1
    - flags:
      - DOTALL
      - MULTILINE
    - bufsize: file

update_spec_changelog:
  file.replace:
    - name: {{ rpm_blddir }}/SPECS/salt-sse.spec
    - pattern: |
        ^%changelog
    - repl: |
        %changelog
        * {{ curr_date }} {{ bld_user }} <{{ bld_user }}@saltstack.com> - {{ git_rev }}-1
        - Test build for user {{ bld_user }}, test release {{ git_rev }}
    - count: 1
    - flags:
      - MULTILINE
    - bufsize: file

