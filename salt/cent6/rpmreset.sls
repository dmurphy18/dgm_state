# clean and prepare system for creating a new rpm package

{% set bld_user = pillar.get('bld_user','saltadmin') %}
{% set rpm_blddir =  pillar.get('bld_user_rpmbuild','/home/saltadmin/rpmbuild') %}
{% set git_blddir =  pillar.get('bld_user_gitbuild','/home/saltadmin/devcode') %}
{% set git_ssedir = pillar.get('bld_user_gitbuild_sse','/home/saltadmin/devcode/sse') %}
{% set git_rev = pillar.get('git_rev','3.1.5') %}

## git v1.7 open centos 6 has issues with https, hence cannot get them directly
{% set git_opensource = pillar.get('git_opensource', 'git@github.com:saltstack/salt.git') %}
{% set git_upstream = pillar.get('git_upstream', 'git@github.com:SS-priv/sse.git') %}


ensure_rpm_blddir:
  file.directory:
    - name: {{ rpm_blddir }}
    - user: {{ bld_user }}
    - group: {{ bld_user }}
    - dir_mode: 775
    - file_mode: 644
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

clean_out_rpmbuild:
  cmd.run:
    - name: rm -fR {{ rpm_blddir }}/*

create_rpmbuild_dirs:
  cmd.run:
    - name: mkdir -p {{ rpm_blddir }}/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
    - user: {{ bld_user }}

create_rpm_macro:
  cmd.run:
    - name: |
        echo "%_topdir {{ rpm_blddir }}" > /home/{{ bld_user }}/.rpmmacros
        echo "%signature gpg" >> /home/{{ bld_user }}/.rpmmacros
        echo "%_gpg_name packaging@saltstack.com" >> /home/{{ bld_user }}/.rpmmacros
    - user: {{ bld_user }}
    - onlyif: test -d /home/{{ bld_user }}
    - require:
      - file: ensure_rpm_blddir
      - cmd: create_rpmbuild_dirs

