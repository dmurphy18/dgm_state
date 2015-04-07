
base:
##  lcminion:
##    - sqldb.sql_db_bldmgr
##    - nginx
##
##  'G@roles:buildbox':
##    - match: compound
##    - build_test

  'cent6-minion and G@roles:buildbox':
    - match: compound
    - cent6.reset
    - cent6.bld_cent6

