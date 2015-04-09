# clean and prepare system for creating a new rpm package

{% set bld_user = pillar.get('bld_user','saltadmin') %}
{% set git_blddir =  pillar.get('bld_user_gitbuild','/home/saltadmin/devcode') %}
{% set git_ssedir = pillar.get('bld_user_gitbuild_sse','/home/saltadmin/devcode/sse') %}
{% set git_rev = pillar.get('git_rev','3.1.5') %}

## git v1.7 open centos 6 has issues with https, hence cannot get them directly
{% set git_opensource = pillar.get('git_opensource', 'git@github.com:saltstack/salt.git') %}
{% set git_upstream = pillar.get('git_upstream', 'git@github.com:SS-priv/sse.git') %}

ensure_git_blddir:
  file.directory:
    - name: {{ git_blddir }}
    - user: {{ bld_user }}
    - group: {{ bld_user }}
    - dir_mode: 775
    - file_mode: 644
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

clean_out_git:
  cmd.run:
    - name: rm -fR {{ git_blddir }}/*

clone_sse:
  cmd.run:
    - name: git clone {{ git_upstream }}
    - cwd: {{ git_blddir }}
    - user: {{ bld_user }}

# ensure sse spec file saved
save_off_user_spec:
  file.copy:
    - name: /home/{{ bld_user }}/salt-sse-el6.spec
    - source: {{ git_ssedir }}/pkg/rpm/sse/salt-sse-el6.spec

# in 2015.2 this won't be needed since file.copy will take a user
ensure_correct_user_spec:
  cmd.run:
    - name: chown {{ bld_user }}:{{ bld_user }} /home/{{ bld_user }}/salt-sse-el6.spec
    - cwd: /home/{{ bld_user }}
    - user: root

add_opensource:
  cmd.run:
    - name: git remote add opensource {{ git_opensource }}
    - cwd: {{ git_ssedir }}
    - user: {{ bld_user }}

add_upstream:
  cmd.run:
    - name: git remote add upstream {{ git_upstream }}
    - cwd: {{ git_ssedir }}
    - user: {{ bld_user }}

git_checkout_version:
  cmd.run:
    - name: git checkout v{{ git_rev }}
    - cwd: {{ git_ssedir }}
    - user: {{ bld_user }}
    - require:
      - file: ensure_git_blddir
      - cmd: clone_sse
      - cmd: ensure_correct_user_spec
      - cmd: add_opensource
      - cmd: add_upstream




