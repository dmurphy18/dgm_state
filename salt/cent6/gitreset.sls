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
    - require:
      - file: ensure_git_blddir

clone_sse:
  cmd.run:
    - name: git clone {{ git_upstream }}
    - cwd: {{ git_blddir }}
    - user: {{ bld_user }}

add_opensource:
  cmd.run:
    - name: git remote add opensource {{ git_opensource }}
    - cwd: {{ git_ssedir }}
    - user: {{ bld_user }}
    - require:
      - cmd: clone_sse

add_upstream:
  cmd.run:
    - name: git remote add upstream {{ git_upstream }}
    - cwd: {{ git_ssedir }}
    - user: {{ bld_user }}
    - require:
      - cmd: add_opensource

git_checkout_version:
  cmd.run:
    - name: git checkout v{{ git_rev }}
    - cwd: {{ git_ssedir }}
    - user: {{ bld_user }}
    - require:
      - cmd: add_upstream



