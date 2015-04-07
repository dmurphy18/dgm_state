## test for state based build system to eventually integrate into !-A-Master
# TODO: 

{% set sql_db_package = salt['pillar.get']('sqldb:lookup:config:sqldb_pkg','') %}
## default setting 

{% set BLDMGR_SCRIPT_VERBOSE = "" %}
{% set BLDMGR_SCRIPT_DEBUG = "" %}
{% set BLDMGR_SCRIPT_LOG = "" %}
{% set BLDMGR_SCRIPT_TAG = "" %}
{% set BLDMGR_SCRIPT_SHAHASH = "" %}
{% set BLDMGR_SCRIPT_BRANCH = "" %}
{% set BLDMGR_SCRIPT_REPO = " -r saltstack/salt " %}
{% set BLDMGR_SCRIPT_EREPO = "" %}
{% set BLDMGR_SCRIPT_USER = "" %}

## verbose handling
{% if salt['pillar.get']('bldmgr:verbose') and salt['pillar.get']('bldmgr:verbose') == 'True' %}
{% set BLDMGR_SCRIPT_VERBOSE = " -v " %}
{% endif %}

## debug handling
{% if salt['pillar.get']('bldmgr:debug') and salt['pillar.get']('bldmgr:debug') == 'True' %}
{% set BLDMGR_SCRIPT_DEBUG = " -d " %}
{% endif %}

## log handling
{% if salt['pillar.get']('bldmgr:log') %}
{% set BLDMGR_SCRIPT_LOG = " -l " ~ salt['pillar.get']('bldmgr:log') ~ " "  %}
{% endif %}

## tag handling
{% if salt['pillar.get']('bldmgr:tag') %}
{% set BLDMGR_SCRIPT_TAG = " -t " ~ salt['pillar.get']('bldmgr:tag') ~ " "  %}
{% endif %}

## shahash handling
{% if salt['pillar.get']('bldmgr:shahash') %}
{% set BLDMGR_SCRIPT_SHAHASH = " -s " ~ salt['pillar.get']('bldmgr:shahash') ~ " "  %}
{% endif %}

## branch handling
{% if salt['pillar.get']('bldmgr:branch') %}
{% set BLDMGR_SCRIPT_BRANCH = " -b " ~ salt['pillar.get']('bldmgr:branch') ~ " "  %}
{% endif %}

## repo handling
{% if salt['pillar.get']('bldmgr:repo') %}
{% set BLDMGR_SCRIPT_REPO = " -r " ~ salt['pillar.get']('bldmgr:repo') ~ " "  %}
{% endif %}

## erepo handling
{% if salt['pillar.get']('bldmgr:erepo') %}
{% set BLDMGR_SCRIPT_EREPO = " -e " ~ salt['pillar.get']('bldmgr:erepo') ~ " "  %}
{% endif %}

## user handling
{% if salt['pillar.get']('bldmgr:user') %}
{% set BLDMGR_SCRIPT_USER = " -u " ~ salt['pillar.get']('bldmgr:user') ~ " "  %}
{% endif %}

# platform build script handling
{% from "bldmgr/map.jinja" import bldmgr with context %}

include:
    - cent6.bld_cent6

