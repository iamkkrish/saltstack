{# Pillar Top File #}

{# Define SSE Servers #}
{% load_yaml as sse_servers %}
  - saltpgsql01
  - saltredis01
  - salteapi01
  - salteapi02
  - saltmaster01
  - saltmaster02
{% endload %}

base:

  {# Assign Pillar Data to SSE Servers #}
  {% for server in sse_servers %}
  '{{ server }}':
    - sse
  {% endfor %}
