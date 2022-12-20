read_ckan_info <- function(url, linkInfo) {
  generalUrl <- paste0(url, "resource_show?id=")
  print(generalUrl)
  linkInfo <- paste0(generalUrl, linkInfo)
  listConf <- jsonlite::fromJSON(linkInfo)
  listConf$result
}


labels_map <- function (nms) {
  label_ftype <- nms
  tooltip <- paste0(
    purrr::map(seq_along(label_ftype), function(i) {
      paste0(label_ftype[i], ": {", label_ftype[i], "}")
    }) %>% unlist(), collapse = "<br/>")
  tooltip
}


