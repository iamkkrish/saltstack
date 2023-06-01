{# Pillar Top File #}

{# Define SSE Servers #}
{% load_yaml as sse_servers %}
  - ssc-pso-cna-master1
  - ssc-pso-cna-raas
  - ssc-pso-cna-postgresql-redis
  - ssc-pso-cna-master2
{% endload %}

base:

  {# Assign Pillar Data to SSE Servers #}
  {% for server in sse_servers %}
  '{{ server }}':
    - sse
  {% endfor %}
