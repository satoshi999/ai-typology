#!/usr/bin/env bash

terraform apply `cat $1 | terraform fmt - | grep -E 'resource |module ' | tr -d '"' | awk '{printf("-target=%s.%s ",$2,$3);}'`