{% set bld_user = pillar.get('bld_user', 'saltadmin') %}

install_mock:
  pkg.installed:
    - name: mock

add_user_mock:
  group.present:
    - name: mock
    - system: True
    - addusers:
      - {{ bld_user }}
    - require:
      - pkg: install_mock

