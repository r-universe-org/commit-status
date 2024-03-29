% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/status.R
\name{gh_app_set_commit_status}
\alias{gh_app_set_commit_status}
\title{Set Commit Status}
\usage{
gh_app_set_commit_status(
  repo,
  sha,
  url,
  universe,
  deployed_packages,
  source_status = NULL,
  docs_status = NULL,
  os_type = NULL
)
}
\arguments{
\item{repo}{full repo name for example "ropensci/magick"}

\item{sha}{hash of the commit to update}

\item{url}{link to the build logs}

\item{universe}{name of the universe where packages were deployed to}

\item{deployed_packages}{string with deployed artifacts}

\item{source_status}{string with result of building source pkg including vignettes}

\item{docs_status}{string with result of building pkgdown documentation}

\item{os_type}{string with OS_type from description}
}
\description{
Sets the commit status on a commit from a GitHub App.
Requires `GH_APP_ID` and `GH_APP_KEY` environment variables.
}
