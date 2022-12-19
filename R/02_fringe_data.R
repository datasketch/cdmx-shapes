#' @export
fringe_data <- function(shape_data) {
  if (is.null(shape_data)) return()
  df <- shape_data@data
  if (is.null(df)) return()
  dic <- homodatum::create_dic(df)
  list(
    data = data,
    dic = dic
  )
}
