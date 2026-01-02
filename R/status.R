#' Set Commit Status
#'
#' Sets the commit status on a commit from a GitHub App.
#' Requires `GH_APP_ID` and `GH_APP_KEY` environment variables.
#'
#' @export
#' @param repo full repo name for example "ropensci/magick"
#' @param pkg name of the package
#' @param ref hash of the commit to update
#' @param buildlog link to the build logs
#' @param universe name of the universe where packages were deployed to
#' @param jobsdata json string with jobs data
gh_app_set_commit_status <- function(repo, pkg, ref, buildlog, universe, jobsdata){
  repo <- sub("https?://github.com/", "", repo)
  repo <- sub("\\.git$", "", repo)
  token <- ghapps::gh_app_token(repo)
  endpoint <- sprintf('/repos/%s/statuses/%s', repo, ref)
  context <- sprintf('r-universe/%s/%s/deploy', universe, pkg)
  description <- 'Deploy binaries to R-universe package server'
  if(jobsdata == 'pending'){
    print(gh::gh(endpoint, .method = 'POST', .token = token, state = 'pending',
                 target_url = buildlog, context = context, description = description))
    return()
  }

  # When run is cancelled or something went wrong in the system, set job to OK
  if(jobsdata == '' || !jsonlite::validate(jobsdata)){
    print(gh::gh(endpoint, .method = 'POST', .token = token, state = 'success',
                 target_url = buildlog, context = context, description = description))
    return()
  }

  # Set final commit status
  jobs <- jsonlite::parse_gzjson_b64(jobsdata)
  state <- release_state(jobs)
  univ_url <- if(state == 'success'){
    sprintf('https://%s.r-universe.dev/%s', universe, pkg)
  } else {buildlog}
  print(gh::gh(endpoint, .method = 'POST', .token = token, state = state,
         target_url = univ_url, context = context, description = description))

  # If there is a pkgdown job, report this separately
  pkgdown <- pkgdown_state(jobs)
  if(length(pkgdown)){
    description <- 'Render pkgdown documentation site'
    state <- ifelse(identical(pkgdown, 'OK'), 'success', 'failure')
    docs_url <- if(state == 'success'){
      paste0('https://docs.ropensci.org/', pkg)
    } else {buildlog}
    print(gh::gh(endpoint, .method = 'POST', .token = token, state = pkgdown,
           target_url = docs_url, context = 'pkgdown-docs', description = description))
  } else {
    message("No pkgdown job found")
  }
}

release_state <- function(df){
  checks <- df[grepl('source|(linux|windows|macos)-(devel|release)', df$config), 'check']
  ifelse(any(grepl("FAIL|ERROR", checks)), 'failure', 'success')
}

pkgdown_state <- function(df){
  check <- df[grepl('pkgdown', df$config), 'check']
  ifelse(check == 'OK', 'success', 'failure')
}
