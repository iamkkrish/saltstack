{% if data["status"] is sameas false %}

call_snow:
  local.snow.create_incident:
    - tgt: {{ data["id"] }}
    - kwarg:
        instance: test
        short_description: "netapp config checker issue"
        description: {{ data["id"] }} filer has config issue;;; {{ data["message"] }}
        path: "test"

{% endif %}
