# customer Mediahub

POC for quotas in ES.

* get_quota_infos.sh  => Use quotactl to get quota  (locally to connector to solve uid/gid names) and print a line for each volume/group/user.
* put_quotas_to_ES.py => Read the  above output and store the data in an ES index.

