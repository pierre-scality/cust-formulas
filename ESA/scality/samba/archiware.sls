
create group archiware:
  group.present:
    - name: archiware
    - gid: 35001

create user archiware:
  user.present:
    - name: archiware
    - uid: 35001
    - gid: archiware

create archiware samba user:
  cmd.run:
    - name: printf 'arcwprd1437\narcwprd1437' | pdbedit -a -u archiware
    - unless: pdbedit -L|grep -w archiware


create user archiwarero:
  user.present:
    - name: archiwarero
    - uid: 35002
    - gid: archiware

create archiwarero samba user:
  cmd.run:
    - name: printf 'archiaccess\narchiaccess' | pdbedit -a -u archiwarero
    - unless: pdbedit -L|grep -w archiwarero
