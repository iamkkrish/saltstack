{# Import SSE Settings #}
{% import_yaml 'sse/sse_settings.yaml' as sse %}


{# Define targeting criteria for stand-alone or multi-node installation #}

{% set sse_eapi_standalone = sse.eapi.eapi_standalone %}
sse_eapi_standalone: {{ sse_eapi_standalone }}

{% set sse_pg_server = sse.servers.pg_server %}
sse_pg_server: {{ sse_pg_server }}

{% set sse_redis_server = sse.servers.redis_server %}
sse_redis_server: {{ sse_redis_server }}

{% set sse_eapi_servers = sse.servers.eapi_servers %}
sse_eapi_servers: {{ sse_eapi_servers|tojson }}

{% set sse_salt_masters = sse.servers.salt_masters %}
sse_salt_masters: {{ sse_salt_masters|tojson }}

{# Set configuration values for stand-alone or multi-node installation #}

{% if sse_eapi_standalone %}

sse_pg_fqdn: localhost
sse_pg_ip: 127.0.0.1

sse_redis_fqdn: localhost
sse_redis_ip: 127.0.0.1

sse_eapi_server_fqdn_list:
  - localhost
sse_eapi_server_fqdn_ip4_list:
  - 127.0.0.1

sse_salt_master_fqdn_list:
  - localhost
sse_salt_master_fqdn_ip4_list:
  - 127.0.0.1

{% else %}

  {# Gather PostgreSQL Server FQDN and IP addresses from Grain cache #}
  {% set pg_grains = salt.saltutil.runner('cache.grains', tgt=sse_pg_server) %}
  {% set pg_fqdn = pg_grains[sse.servers.pg_server].fqdn %}
  {% set pg_ipv4_all = pg_grains[sse.servers.pg_server].ipv4 %}
  {% set pg_ipv4_exclude_localhost = [] %}
  {% for pg_ipv4 in pg_ipv4_all if pg_ipv4 != '127.0.0.1' %}
  {% do pg_ipv4_exclude_localhost.append(pg_ipv4) %}
  {% endfor %}
sse_pg_fqdn: {{ pg_fqdn }}
sse_pg_ip: {{ pg_ipv4_exclude_localhost|first }}

  {# Gather eAPI Servers FQDN and IP addresses from Grain cache #}
  {% set eapi_server_fqdn_list = [] %}
  {% set eapi_server_ipv4_list = [] %}
  {% for eapi_server in sse_eapi_servers %}
    {% set eapi_server_grains = salt.saltutil.runner('cache.grains', tgt=eapi_server) %}
    {% do eapi_server_fqdn_list.append(eapi_server_grains[eapi_server].fqdn) %}
    {% for eapi_ipv4 in eapi_server_grains[eapi_server].ipv4 if eapi_ipv4 != '127.0.0.1' %}
    {% do eapi_server_ipv4_list.append(eapi_ipv4) %}
    {% endfor %}
  {% endfor %}
sse_eapi_server_fqdn_list: {{ eapi_server_fqdn_list|tojson }}
sse_eapi_server_ipv4_list: {{ eapi_server_ipv4_list|tojson }}

  {# Gather Salt Master Servers FQDN and IP addresses from Grain cache #}
  {% set salt_master_fqdn_list = [] %}
  {% set salt_master_ipv4_list = [] %}
  {% for salt_master in sse_salt_masters %}
    {% set salt_master_grains = salt.saltutil.runner('cache.grains', tgt=salt_master) %}
    {% do salt_master_fqdn_list.append(salt_master_grains[salt_master].fqdn) %}
    {% for salt_master_ipv4 in salt_master_grains[salt_master].ipv4 if salt_master_ipv4 != '127.0.0.1' %}
    {% do salt_master_ipv4_list.append(salt_master_ipv4) %}
    {% endfor %}
  {% endfor %}
sse_salt_master_fqdn_list: {{ salt_master_fqdn_list|tojson }}
sse_salt_master_ipv4_list: {{ salt_master_ipv4_list|tojson }}

{% endif %}


{# Gather PostgreSQL Server settings #}
sse_pg_endpoint: {{ sse.pg.pg_endpoint }}
sse_pg_port: {{ sse.pg.pg_port }}
sse_pg_username: {{ sse.pg.pg_username }} 
sse_pg_password: {{ sse.pg.pg_password }}
sse_pg_cert_cn: {{ sse.pg.pg_cert_cn }}
sse_pg_cert_name: {{ sse.pg.pg_cert_name }}


{# Specify if PostgreSQL Host Based Authentication should use FQDN and/or IP #}
sse_pg_hba_by_fqdn: {{ sse.pg.pg_hba_by_fqdn }}
sse_pg_hba_by_ip: {{ sse.pg.pg_hba_by_ip }}


{# Gather Redis Server settings #}
sse_redis_endpoint: {{ sse.redis.redis_endpoint }}
sse_redis_port: {{ sse.redis.redis_port }}
sse_redis_username: {{ sse.redis.redis_username }} 
sse_redis_password: {{ sse.redis.redis_password }}


{# Gather eAPI Server settings #}
sse_eapi_endpoint: {{ sse.eapi.eapi_endpoint }}
sse_eapi_username: {{ sse.eapi.eapi_username }}
sse_eapi_password: {{ sse.eapi.eapi_password }}
sse_eapi_key: {{ sse.eapi.eapi_key }}
sse_eapi_failover_master: {{ sse.eapi.eapi_failover_master }}
sse_eapi_ssl_enabled: {{ sse.eapi.eapi_ssl_enabled }}
sse_eapi_ssl_validation: {{ sse.eapi.eapi_ssl_validation }}
sse_eapi_num_processes: {{ grains['num_cpus'] * 3 }}
sse_eapi_server_cert_cn: {{ sse.eapi.eapi_server_cert_cn }}
sse_eapi_server_cert_name: {{ sse.eapi.eapi_server_cert_name }}


{# Set identifiers #}
sse_customer_id: {{ sse.ids.customer_id }}
sse_cluster_id: {{ sse.ids.cluster_id }}
