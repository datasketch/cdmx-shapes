#' @export
plot_shapes <- function(shape_data, opts) {
  if (is.null(shape_data)) return()
  shape_class <- class(shape_data)[1]

  lf <- leaflet::leaflet() |>
    leaflet::addTiles(urlTemplate = "https://maps.geoapify.com/v1/tile/positron/{z}/{x}/{y}.png?&apiKey=f39345000acd4188aae1f2f4eed3ff14",
                      attribution = "positron")


  if (shape_class == "SpatialLinesDataFrame") {
    lf <- lf |>
      leaflet::addPolylines(data = shape_data, label = ~labels, color = "red")
  }
  if (shape_class == "SpatialPointsDataFrame") {
    lf <- lf |>
      leaflet::addCircleMarkers(data = shape_data, label = ~labels)
  }
  if (shape_class == "SpatialPolygonsDataFrame") {
    lf <- lf |>
      leaflet::addPolygons(data = shape_data, label = ~labels)
  }

  lf

}
