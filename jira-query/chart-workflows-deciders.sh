#/bin/bash

set -e -o pipefail

mypassword=$1

if [ "$#" -ne 1 ]; then
	read -s -p "Password for JIRA:" mypassword
fi

ROOT='https://jira.oicr.on.ca/rest/api/2/search'


declare -a types=("workflows" "deciders");
declare -a classifiers=("bugs" "features" "upgrade" "testing");
CMD="Rscript parseJIRAJSON.R PDE-WorkflowsAndDeciders";

for t in "${types[@]}"
do
	for c in "${classifiers[@]}"
	do
		curl -u mtaschuk:${mypassword} -k "$ROOT?maxResults=1000&jql=project=PDE+AND+labels+in+(${t},${c})+AND+status+in+(Resolved,Closed)" > ${t}-${c}
		CMD="${CMD} ${t}-${c}";
	done
done

echo $CMD;
eval $CMD;
for t in "${types[@]}"
do
	rm ${t}*
done
