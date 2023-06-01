{#
  Salt State to Install and Configure PostgreSQL
#}

{# Specify the version of PostgreSQL #}
{% set pg_version = "13.8" %}
{% set pg_major = "13" %}


{% set sse_pg_username = salt['pillar.get']('sse_pg_username', "salt_eapi") %}
{% set sse_pg_password = salt['pillar.get']('sse_pg_password', "abc123") %}
{% set sse_pg_port = salt['pillar.get']('sse_pg_port', "5432") %}
{% set sse_pg_hba_by_fqdn = salt['pillar.get']('sse_pg_hba_by_fqdn', False) %}
{% set sse_pg_hba_by_ip = salt['pillar.get']('sse_pg_hba_by_ip', True) %}

{% if salt['sdb.get']('sdb://osenv/PG_CERT_CN') and salt['sdb.get']('sdb://osenv/PG_CERT_CN') != 'sdb://osenv/PG_CERT_CN' %}
{% set sse_pg_cert_cn = salt['sdb.get']('sdb://osenv/PG_CERT_CN') %}
{% set sse_pg_cert_name = sse_pg_cert_cn %}
{% else %}
{% set sse_pg_cert_cn = salt['pillar.get']('sse_pg_cert_cn', 'localhost') %}
{% set sse_pg_cert_name = salt['pillar.get']('sse_pg_cert_name', 'localhost') %}
{% endif %}
{% set sse_pg_cert = "/etc/pki/postgres/certs/"+sse_pg_cert_name+".crt" %}
{% set sse_pg_key = "/etc/pki/postgres/certs/"+sse_pg_cert_name+".key" %}
{# Set FQDNs to allow in pg_hba.conf #}
{% set sse_pg_hba_fqdn_list = [] %}

  {% set sse_eapi_server_fqdn_list = salt['pillar.get']('sse_eapi_server_fqdn_list', []) %}
  {% for sse_eapi_server_fqdn in sse_eapi_server_fqdn_list %}
  {% do sse_pg_hba_fqdn_list.append(sse_eapi_server_fqdn) %}
  {% endfor %}

  {% set sse_salt_master_fqdn_list = salt['pillar.get']('sse_salt_master_fqdn_list', []) %}
  {% for sse_salt_master_fqdn in sse_salt_master_fqdn_list %}
  {% do sse_pg_hba_fqdn_list.append(sse_salt_master_fqdn) %}
  {% endfor %}

{# Set IP addresses to allow in pg_hba.conf #}
{% set sse_pg_hba_ip_list = [] %}

  {% set sse_eapi_server_ipv4_list = salt['pillar.get']('sse_eapi_server_ipv4_list', []) %}
  {% for sse_eapi_server_ipv4 in sse_eapi_server_ipv4_list %}
  {% do sse_pg_hba_ip_list.append(sse_eapi_server_ipv4) %}
  {% endfor %}

  {% set sse_salt_master_ipv4_list = salt['pillar.get']('sse_salt_master_ipv4_list', []) %}
  {% for sse_salt_master_ipv4 in sse_salt_master_ipv4_list %}
  {% do sse_pg_hba_ip_list.append(sse_salt_master_ipv4) %}
  {% endfor %}

install_postgresql-server:
  pkg.installed:
    - sources:
      - postgresql{{ pg_major }}-libs: salt://{{ slspath }}/files/postgresql13-libs-13.8-1PGDG.rhel9.x86_64.rpm
      - postgresql{{ pg_major }}: salt://{{ slspath }}/files/postgresql13-13.8-1PGDG.rhel9.x86_64.rpm
      - postgresql{{ pg_major }}-server: salt://{{ slspath }}/files/postgresql13-server-13.8-1PGDG.rhel9.x86_64.rpm
      - postgresql{{ pg_major }}-contrib: salt://{{ slspath }}/files/postgresql13-contrib-13.8-1PGDG.rhel9.x86_64.rpm
      - glibc-langpack-en: salt://{{ slspath }}/files/glibc-langpack-en-2.34-28.el9_0.2.x86_64.rpm

initialize_postgres-database:
  cmd.run:
    - env:
      - PGSETUP_INITDB_OPTIONS: '-E UTF8'
      - LANG: "en_US.utf-8"
      - LC_ALL: "en_US.UTF-8"
    - name: /usr/pgsql-{{ pg_major }}/bin/postgresql-{{ pg_major }}-setup initdb
    - onchanges:
      - pkg: install_postgresql-server

create_pki_postgres_path:
  file.directory:
    - name: /etc/pki/postgres/certs
    - makedirs: True
    - dir_mode: 755

create_ssl_certificate:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: postgres
    - CN: {{ sse_pg_cert_cn }}
    - cert_filename: {{ sse_pg_cert_name }}
    - require:
      - file: create_pki_postgres_path
    - onchanges:
      - file: create_pki_postgres_path

set_certificate_permissions:
  file.managed:
    - name: {{ sse_pg_cert }}
    - mode: 400
    - user: postgres
    - group: postgres
    - replace: False
    - create: False
    - require:
      - file: create_pki_postgres_path

set_key_permissions:
  file.managed:
    - name: {{ sse_pg_key }}
    - mode: 400
    - user: postgres
    - group: postgres
    - replace: False
    - create: False
    - require:
      - file: create_pki_postgres_path

configure_postgres:
  file.managed:
    - name: /var/lib/pgsql/{{ pg_major }}/data/postgresql.conf
    - source: salt://{{ slspath }}/files/postgresql.conf.jinja
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 600
    - context:
        sse_pg_port: {{ sse_pg_port }}
        sse_pg_cert: {{ sse_pg_cert }}
        sse_pg_key: {{ sse_pg_key }}
    - require:
      - pkg: install_postgresql-server

configure_pg_hba:
  file.managed:
    - name: /var/lib/pgsql/{{ pg_major }}/data/pg_hba.conf
    - source: salt://{{ slspath }}/files/pg_hba.conf.jinja
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 600
    - context:
        sse_pg_username: {{ sse_pg_username }}
        sse_pg_hba_by_fqdn: {{ sse_pg_hba_by_fqdn }}
        sse_pg_hba_by_ip: {{ sse_pg_hba_by_ip }}
        sse_pg_hba_fqdn_list: {{ sse_pg_hba_fqdn_list|tojson }}
        sse_pg_hba_ip_list: {{ sse_pg_hba_ip_list|tojson }}
    - require:
      - pkg: install_postgresql-server

start_postgres:
  service.running:
    - name: postgresql-{{ pg_major }}
    - enable: True
    - watch:
      - file: configure_postgres
      - file: configure_pg_hba
      - pkg: install_postgresql-server

create_db_user:
  postgres_user.present:
    - name: {{ sse_pg_username }}
    - password: {{ sse_pg_password }}
    - db_port: {{ sse_pg_port }}
    - superuser: True
