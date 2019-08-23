/etc/sagentd.yaml:
  file.append:
   - source: salt://scality/ha1/sagentd.tmpl
   - template: jinja
   - require_in:
     - service: scality-sagentd
  service.running:
    - name: scality-sagentd
    - enable: True
    - watch:
      - file: /etc/sagentd.yaml

