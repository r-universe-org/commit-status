#' Set Commit Status
#'
#' Sets the commit status on a commit from a GitHub App.
#' Requires `GH_APP_ID` and `GH_APP_KEY` environment variables.
#'
#' @export
#' @param repo full repo name for example "ropensci/magick"
#' @param sha hash of the commit to update
#' @param url link to the build logs
#' @param universe name of the universe where packages were deployed to
#' @param deployed_packages string with deployed artifacts
#' @param source_status string with result of building source pkg including vignettes
#' @param docs_status string with result of building pkgdown documentation
#' @param os_type string with OS_type from description
gh_app_set_commit_status <- function(repo, pkg, sha, url, universe, deployed_packages,
                                     source_status = NULL, docs_status = NULL, os_type = NULL){
  repo <- sub("https?://github.com/", "", repo)
  repo <- sub("\\.git$", "", repo)
  token <- ghapps::gh_app_token(repo)
  endpoint <- sprintf('/repos/%s/statuses/%s', repo, sha)
  context <- sprintf('r-universe/%s/%s/deploy', universe, pkg)
  description <- 'Deploy binaries to R-universe package server'
  state <- if(grepl('pending', deployed_packages)){
    'pending'
  } else if(is_success(deployed_packages, source_status, os_type)){
    'success'
  } else {
    'failure'
  }
  univ_url <- if(state == 'success'){
    sprintf('https://%s.r-universe.dev/%s', universe, pkg)
  } else {url}
  print(gh::gh(endpoint, .method = 'POST', .token = token, state = state,
         target_url = univ_url, context = context, description = description))

  # relay status for pkgdown render job
  if(identical(docs_status, 'failure') || identical(docs_status, 'success')){
    description <- 'Render pkgdown documentation site'
    docs_url <- if(grepl('success', docs_status)){
      paste0('https://docs.ropensci.org/', pkg)
    } else {url}
    print(gh::gh(endpoint, .method = 'POST', .token = token, state = docs_status,
           target_url = docs_url, context = 'pkgdown-docs', description = description))
  }

  # Temp fix: reset old broken statuses
  if(state != 'pending') {
    endpoint2 <- sprintf('/repos/%s/commits/%s/status', repo, sha)
    statuses <- gh::gh(endpoint2, .token = token)$statuses
    pending <- Find(function(x){
      return(x$state == 'pending' && x$context == context)
    }, statuses)
    if(length(pending)){
      print("Finalizing broken status update...")
      print(gh::gh(pending$url, .method = 'POST', .token = token, state = state,
                   target_url = univ_url, context = pending$context, description = description))
    } else {
      print("No broken status update needed.")
    }
  }
}

is_success <- function(deployed_packages, source_status, os_type){
  src_ok <- !identical(source_status, 'failure')
  win_ok <- grepl("windows-release", deployed_packages) || grepl('unix', os_type)
  mac_ok <- grepl("macos-release", deployed_packages) || grepl('win', os_type)
  return(src_ok && win_ok && mac_ok)
}

# Does not work with current app permissions
comment_failed_deployment <- function(url){
  token <- ghapps::gh_app_token('r-universe-org/bugs')
  endpoint <- '/repos/r-universe-org/bugs/issues/123/comments'
  body <- sprintf("Test: %s", url)
  print(gh::gh(endpoint, .method = 'POST', .token = token, body = body))
}
