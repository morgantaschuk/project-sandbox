#/bin/bash

set -e -o pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mypassword=$1

if [ "$#" -ne 1 ]; then
	read -s -p "Password for JIRA:" mypassword
fi

bash $DIR/chart-alltime.sh $mypassword
bash $DIR/chart-last30days.sh $mypassword
bash $DIR/chart-workflows-deciders.sh $mypassword
bash $DIR/chart-labels.sh $mypassword



