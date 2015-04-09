{% set bld_user = pillar.get('bld_user','saltadmin') %}
{% set rpm_blddir =  pillar.get('bld_user_rpmbuild','/home/saltadmin/rpmbuild') %}
{% set git_ssedir = pillar.get('bld_user_gitbuild_sse','/home/saltadmin/devcode/sse') %}
{% set git_rev = pillar.get('git_rev','3.1.5') %}

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

generate_spec_patch:
  file.append:
    - name: {{ rpm_blddir }}/SPECS/spec.patch
    - template: jinja
    - text: |
        --- salt-sse.spec 2015-04-03 18:15:23.240483735 -0600
        +++ salt-sse.spec.new	2015-04-03 16:21:12.884126945 -0600
        @@ -7,12 +7,12 @@
         %global include_tests 0
         
         %define _salttesting SaltTesting
        -%define _salttesting_ver 2014.4.24
        +%define _salttesting_ver 2014.8.5
         
         %define srcname salt
         Name: %{srcname}-enterprise
        -Version: 3.1.4
        -Release: 2%{?dist}
        +Version: {{ git_rev }}
        +Release: 1%{?dist}
         Summary: A parallel remote execution system (Enterprise Edition)
         
         Group:   System Environment/Daemons
        @@ -100,6 +100,8 @@
         cd $RPM_BUILD_DIR/%{name}-%{version}/%{srcname}-%{version}
         %{__python2} setup.py install -O1 --root $RPM_BUILD_ROOT
         
        +find $RPM_BUILD_ROOT -type f -name '*egg*'
        +
         mkdir -p $RPM_BUILD_ROOT%{_initrddir}
         install -p %{SOURCE2} $RPM_BUILD_ROOT%{_initrddir}/
         install -p %{SOURCE3} $RPM_BUILD_ROOT%{_initrddir}/
        @@ -190,6 +192,15 @@
           fi
         
         %changelog
        +* {{ curr_date }} {{ bld_user }} <{{ bld_user }}@saltstack.com> - {{ git_rev }}-1
        +- Test build {{ git_rev }}
        +
        +* Wed Jan 21 2015 Erik Johnson <erik@saltstack.com> - 3.1.5-1
        +- Security release 3.1.5
        +
        +* Fri Aug  1 2014 Erik Johnson <erik@saltstack.com> - 3.1.4.1-1
        +- Security release 3.1.4.1
        +
         * Thu Jul 17 2014 Erik Johnson <erik@saltstack.com> - 3.1.4-2
         - Add hard dep on python-libcloud for the master

# in 2015.2 this won't be needed since file.copy will take a user
ensure_correct_user_patch:
  cmd.run:
    - name: chown {{ bld_user }}:mock {{ rpm_blddir }}/SPECS/spec.patch
    - cwd: {{ rpm_blddir }}/SPECS
    - user: root

apply_spec_patch:
  cmd.run:
    - name: patch -N < {{ rpm_blddir }}/SPECS/spec.patch
    - cwd: {{ rpm_blddir }}/SPECS
    - user: {{ bld_user }}
    - template: jinja
    - require:
      - file: update_rpmbuild_with_sdist
      - file: generate_spec_patch
      - cmd: ensure_correct_user_patch

