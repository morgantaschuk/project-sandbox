#/bin/bash

set -e -o pipefail

read -s -p "Password for JIRA:" mypassword

SUFF='@oicr.on.ca'
ROOT='https://jira.oicr.on.ca/rest/api/2/search'


declare -a names=("mtaschuk" "pruzanov" "mlaszloffy" "tbeck" "xluo" 'michael.moorhouse@oicr.on.ca' "tdebat" "ysundaravadanam" "lheisler" "dyuen");
CMD="Rscript parseJIRAJSON.R TicketsFromAllTime";
for n in "${names[@]}"
do
	curl -u mtaschuk:${mypassword} -k "$ROOT?maxResults=1000&jql=assignee=\"${n}\"+AND+status+in+(Resolved,Closed)" > ${n%$SUFF}
	CMD="${CMD} ${n%$SUFF}";
done

echo $CMD;
eval $CMD;

CMD="Rscript parseJIRAJSON.R TicketsClosedLast30days";
for n in "${names[@]}"
do
	curl -u mtaschuk:${mypassword} -k "$ROOT?maxResults=1000&jql=assignee=\"${n}\"+AND+resolved>=-30d" > ${n%$SUFF}-30
	CMD="${CMD} ${n%$SUFF}-30";
done

echo $CMD;
eval $CMD;

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






for n in "${names[@]}"
do
	rm ${n%$SUFF}*
done

for t in "${types[@]}"
do
	rm ${t}*
done
