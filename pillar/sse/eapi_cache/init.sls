{#
  Salt State to Install and Configure Redis
#}

{% set sse_redis_password = salt['pillar.get']('sse_redis_password', "abc123") %}
{% set sse_redis_port = salt['pillar.get']('sse_redis_port', "6379") %}
{% set sse_eapi_server_ipv4_list = salt['pillar.get']('sse_eapi_server_ipv4_list', []) %}

install_redis:
  pkg.installed:
    - sources:
      - logrotate: salt://{{ slspath }}/files/logrotate-3.18.0-5.el9.x86_64.rpm
      - redis: salt://{{ slspath }}/files/redis-6.2.7-1.el9.remi.x86_64.rpm

configure_redis:
  file.managed:
    - name: /etc/redis.conf
    - source: salt://{{ slspath }}/files/redis.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 664
    - context:
        sse_redis_password: {{ sse_redis_password }}
        sse_redis_port: {{ sse_redis_port }}
        sse_eapi_server_ipv4_list: {{ sse_eapi_server_ipv4_list|tojson }}

start_redis:
  service.running:
    - name: redis
    - enable: True
    - require:
      - pkg: install_redis
