#!/bin/bash -l
set -e

# Temporary disable
HAS_APP=""

if [ "${HAS_APP}" ]; then
echo "Trying to set commit status for ${REPO}/commit/${SHA}"
echo "Source status: ${SOURCE_STATUS}"
echo "Docs status: ${DOCS_STATUS}"
Rscript -e "commitstatus::gh_app_set_commit_status('${REPO}', '${PACKAGE}', '${SHA}','${BUILDLOG}','${UNIVERSE}','${DEPLOYED_PACKAGES}', '${SOURCE_STATUS}', '${DOCS_STATUS}', '${OSTYPE}')"
fi

#if [ "${DEPLOYED_PACKAGES}" != "pending" ] && [ -z "${IS_REBUILD}" ]; then
#echo "Create deployment for ${PACKAGE} in https://github.com/r-universe/${UNIVERSE}"
#Rscript -e "commitstatus::update_deployment_status('${UNIVERSE}', '${PACKAGE}', '${GITHUB_SHA}','${BUILDLOG}', '${SOURCE_STATUS}')"
#fi

echo "Action complete!"
