#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim: tabstop=4:shiftwidth=4:smarttab:expandtab:softtabstop=4:autoindent

## requisites
# sudo pip install elasticsearch

from datetime import datetime
from elasticsearch import Elasticsearch
from elasticsearch import ElasticsearchException
from elasticsearch.helpers import bulk
import pprint
import socket
import yaml
import sys
import os

datainputfile="/root/quota.out"
hostname = socket.gethostname().split('.', 1)[0]
sagent_file = '/etc/sagentd.yaml'
grain_file = "/etc/salt/grains"

try:
    with open(sagent_file, 'r') as data:
        sagent_conf = yaml.load(data)
except IOError:
    sys.exit(1)

try:
    with open(grain_file, 'r') as data:
        grain_conf = yaml.load(data)
except IOError:
    sys.exit(1)

try:
    es_nodes = sagent_conf['stats_poll_hosts']
except:
    # not initialized
    sys.exit(1)

# Index creation settings
index_name = 'quotas-stats'
index_alias = 'quotas-stats'
index_settings = {
    "settings" : {
        "number_of_shards": 3,
        "number_of_replicas": 1,
        "index.codec": "best_compression"
    },
    "mappings" : {
        "quotas-stats" : {
            "properties" : {
                "groupname" : {
                    "type" : "string",
                    "index": "not_analyzed"
                },
                "id" : {
                    "type" : "long"
                },
                "inodes" : {
                    "type" : "long"
                },
                "name" : {
                    "type" : "keyword"
                }, 
                "size" : {
                    "type" : "long"
                },
                "type" : {
                    "type" : "keyword"
                },
                "volume" : {
                    "type" : "long"
                }
            }
        }
    }
}

def parse_groupstat():
  try:
    lines = open(datainputfile, "r").readlines()
  except Exception:
    print "Can't open quota file {}".format(datainputfile)
    return False
 
  arr_status = []
  cols = [ "type", "volume", "id", "name", "inodes", "size" ]
  for line in lines:
    val = line.split()
    typ = val[0]
    #del val[0] # this field was not included in Cedrick version
    for i in range(len(val)):
      if val[i].isdigit():
        val[i]=int(val[i])
    lineData = dict(zip(cols, val))
    print lineData
    lineData.update({'timestamp': ltime, "tag": "quotas", "type": typ})
    arr_status.append(lineData)
      
  return arr_status

def create_index(es, index, alias):
    idx = '{name}-{ts}'.format(name=index, ts=today)
    try:
        if not es.indices.exists(index=idx):
            # ignore 400 cause by IndexAlreadyExistsException when creating an index
            es.indices.create(index=idx, body=index_settings, ignore=400)
            es.indices.put_alias(index=idx, name=alias)
    except ElasticsearchException as e:
        print 'ES Error: {0}'.format(e.error)
        return False
    except Exception:
        print "Generic Exception: {}".format(traceback.format_exc())
        return False

if __name__ == '__main__':
    es = Elasticsearch(es_nodes, port="9200")

    now = datetime.utcnow()
    ltime = now.strftime("%Y-%m-%dT%H:%M:%S") + ".%03d" % (now.microsecond / 1000) + "Z"
    today = now.strftime("%Y.%m.%d")
    index_date = '{name}-{date}'.format(name = index_name, date = today)

    group_stats = []

    groupstat_info = parse_groupstat()
    if groupstat_info:
        group_stats.extend(groupstat_info)
    #print group_stats
    #exit()
    create_index(es, index_name, index_alias)
    try:
        import pprint
        #bulk(es, group_stats, index = index_date, doc_type=index_name, raise_on_error = False)
        #print "toto es, group_stats, index = index_date, doc_type=index_name, raise_on_error = False"
        bulk(es, group_stats, index = index_date, doc_type=index_name, raise_on_error = False)
    except ElasticsearchException as e:
        print 'ES Error: {0}'.format(e.error)
    except Exception:
        print "Generic Exception: {}".format(traceback.format_exc())
    else:
        print "entry done"
