{% set bld_user = pillar.get('bld_user','saltadmin') %}
{% set rpm_blddir =  pillar.get('bld_user_rpmbuild','/home/saltadmin/rpmbuild') %}
{% set git_blddir =  pillar.get('bld_user_gitbuild','/home/saltadmin/devcode') %}
{% set git_ssedir = pillar.get('bld_user_gitbuild_sse','/home/saltadmin/devcode/sse') %}
{% set git_rev = pillar.get('git_rev','3.1.5') %}

## git v1.7 open centos 6 has issues with https, hence cannot get them directly
{% set git_opensource = pillar.get('git_opensource', 'git@github.com:saltstack/salt.git') %}
{% set git_upstream = pillar.get('git_upstream', 'git@github.com:SS-priv/sse.git') %}
{% set curr_date = None | strftime("%a %b %d %Y") %}

include:
  - cent6
  - .prepare_spec
  - .prepare_salttest

generate_src_rpm:
  cmd.run:
    - name: rpmbuild -bs --define "_source_filedigest_algorithm md5" --define "_binary_filedigest_algorithm md5"  {{ rpm_blddir }}/SPECS/salt-sse.spec
    - cwd: {{ rpm_blddir }}/SRPMS
    - user: {{ bld_user }}



