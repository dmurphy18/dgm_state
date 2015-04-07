
include:
  - cent6
  - .mock
  - .reset

file_check:   # sanity check
  file.exists:
    - name: /etc/yum.repos.d/epel.repo
    -require:
      - pkg: install_mock


