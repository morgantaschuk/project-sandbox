#/bin/bash

read -s -p "Password for JIRA:" mypassword


declare -a names=("mtaschuk" "pruzanov" "mlaszloffy");

for n in "${names[@]}"
do
	curl -u mtaschuk:${mypassword} -k "https://jira.oicr.on.ca/rest/api/2/search?jql=project=PDE+AND+assignee=${n}" > ${n}-alltime
done

CMD="Rscript parseJIRAJSON.R alltime";

for n in "${names[@]}"
do
	CMD="${CMD} ${n}-alltime";
done
eval $CMD;


for n in "${names[@]}"
do
	rm ${n}-alltime
done
