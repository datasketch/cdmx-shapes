#' @export
unzip_shape <- function(url, export_dir) {
  file_destiny <- paste0(tempdir(check = TRUE), "shape_file.zip")
  download.file(url, destfile = file_destiny)
  unzip(zipfile = file_destiny, exdir = export_dir)
  folder_info <- fs::dir_ls(path =  export_dir, type = "file", recurse = TRUE)
  shape_info <- stringr::str_split(folder_info, pattern = "/") |>
    unlist() |>
    setdiff(export_dir)
  shape_dsn <- shape_info[1]
  shape_info <- shape_info[-1]
  ext <- substring(shape_info,
                   regexpr("\\.([[:alnum:]]+)$", shape_info) + 1L)
  shape_layer <- gsub(paste0(".", ext, collapse = "|"), "", shape_info) |>
    unique()
  list(
    shape_file = export_dir,
    shape_dsn = shape_dsn,
    shape_layer = shape_layer
  )
}
