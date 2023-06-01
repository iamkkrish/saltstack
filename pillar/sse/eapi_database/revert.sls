revert_all:

  pkg.removed:
    - pkgs:
      - postgresql12-contrib
      - postgresql12-libs
      - postgresql12-server
      - postgresql12

  file.absent:
    - names:
      - /var/lib/pgsql/
      - /etc/pki/postgres/

  user.absent:
    - name: postgres
