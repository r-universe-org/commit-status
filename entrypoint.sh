#!/bin/bash -l
set -e
echo "Trying to set commit status for ${REPOSITORY}/commit/${REF}"
Rscript -e "commitstatus::gh_app_set_commit_status('${REPOSITORY}', '${PACKAGE}', '${REF}','${BUILDLOG}','${UNIVERSE}','${JOBDATA}')"
