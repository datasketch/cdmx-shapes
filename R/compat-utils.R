read_ckan_info <- function(url, linkInfo) {
  generalUrl <- paste0(url, "resource_show?id=")
  print(generalUrl)
  linkInfo <- paste0(generalUrl, linkInfo)
  listConf <- jsonlite::fromJSON(linkInfo)
  listConf$result
}
