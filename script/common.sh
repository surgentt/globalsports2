#!/bin/bash

# GS common script vars
# include with . `dirname $0`/common.sh

RAILS_ROOT=${RAILS_ROOT:-`dirname $0`/..}
export RAILS_ENV=${RAILS_ENV:-"production"}
PATH=/usr/local/bin:/bin:/usr/bin:${PATH}
LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

[[ -s "/usr/local/lib/rvm" ]] && . "/usr/local/lib/rvm"

cd ${RAILS_ROOT}

