#' @export
read_shape <- function(url, export_dir) {
  export_dir <- "temporal"
  file_destiny <- paste0(tempdir(check = TRUE), "shape_file.zip")
  download.file(url, destfile = file_destiny)
  unzip(zipfile = file_destiny, exdir = export_dir)
  folder_info <- fs::dir_ls(path =  "temporal/", type = "file", recurse = TRUE)
  shape_info <- str_split(folder_info[1], pattern = "/") |>
    unlist() |>
    setdiff(export_dir)
  shape_dsn <- paste0(export_dir, "/",shape_info[1])
  ext <- substring(shape_info[2],
                   regexpr("\\.([[:alnum:]]+)$", shape_info[2]) + 1L)
  shape_layer <- gsub(paste0(".", ext), "", shape_info[2])
  shape_data <- rgdal::readOGR(
    dsn = shape_dsn,
    layer = shape_layer,
    verbose=FALSE
  )
}
