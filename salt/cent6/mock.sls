{% set bld_user = pillar.get('bld_user', 'saltadmin') %}

# install_py_ctypes:
#   pkg.installed:
#     - name: python-ctypes

install_mock:
  pkg.installed:
    - name: mock
#    - requires:
#      - pkg: install_py_ctypes

## sudo usermod -a -G mock saltadmin && newgrp mock
## add build user to mock group
add_user_mock:
  cmd.run:
    - name: usermod -a -G mock {{ bld_user }} && newgrp mock
    - user: root
    - require:
      - pkg: install_mock


