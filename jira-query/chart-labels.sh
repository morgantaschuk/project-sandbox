#/bin/bash

set -e -o pipefail

mypassword=$1

if [ "$#" -ne 1 ]; then
	read -s -p "Password for JIRA:" mypassword
fi

ROOT='https://jira.oicr.on.ca/rest/api/2/search'


declare -a types=("workflows" "deciders" "bugs" "documentation" "evaluations" "features" "hiring" "implementation" "informational" "SeqWare" "maintenance" "metadata" "publications" "refactoring" "reports" "requirements" "testing" "training" "upgrade");


CMD="Rscript parseJIRAJSON.R PDE-Labels";

for t in "${types[@]}"
do
	curl -u mtaschuk:${mypassword} -k "$ROOT?maxResults=1000&jql=project=PDE+AND+labels+in+(${t})+AND+status+in+(Resolved,Closed)" > ${t}
	CMD="${CMD} ${t}";
done

echo $CMD;
eval $CMD;
for t in "${types[@]}"
do
	rm ${t}*
done
