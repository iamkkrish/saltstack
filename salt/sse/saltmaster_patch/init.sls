{% if salt.match.grain('saltversion:3004*') %}

install-patch-dependencies:
  pkg.installed:
    - name: patch

patch-salt-master:
  file.patch:
    - name: {{salt.grains.get('saltpath', '/usr/lib/python3.7/site-packages/salt')}}
    - source: salt://{{ slspath }}/files/salt-3004.patch
    - strip: 1
    - require:
      - pkg: install-patch-dependencies
{% else %}
not on 3004:
  test.show_notification:
    - text: Not on compatible version
{%endif %}

{% if salt.match.grain('saltversion:3005*') %}

{{salt.grains.get('saltpath') + '/cloud/clouds/saltify.py'}}:
  file.managed:
    - source: salt://{{ slspath }}/files/saltify.py
    - replace: True

{% else %}
not on 3005:
  test.show_notification:
    - text: Not on compatible version
{%endif %}
