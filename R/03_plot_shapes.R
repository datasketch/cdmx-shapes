#' #' @export
#' plot_shapes <- function(shape_data, opts) {
#'   if (is.null(shape_data)) return()
#'   shape_class <- class(shape_data)[1]
#'   shape_transform <- spTransform(shape_data, CRS("+init=epsg:4326"))
#'
#'   if (shape_class == "SpatialLinesDataFrame") {
#'
#'   }
#'   if (shape_class == "SpatialPolygonsDataFrame") {
#'
#'   }
#'
#' }
