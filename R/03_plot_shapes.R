#' @export
plot_shapes <- function(shape_data, opts) {
  if (is.null(shape_data)) return()
  shape_class <- class(shape_data)[1]

  lf <- leaflet::leaflet() |>
    leaflet::addTiles(urlTemplate = "https://maps.geoapify.com/v1/tile/positron/{z}/{x}/{y}.png?&apiKey=f39345000acd4188aae1f2f4eed3ff14",
                      attribution = "positron")


  if (shape_class == "SpatialLinesDataFrame") {
    lf <- lf |>
      leaflet::addPolylines(data = shape_data,
                            label = ~labels,
                            color = opts$colors,
                            fillOpacity = 1,
                            weight = 3)
  }
  if (shape_class == "SpatialPointsDataFrame") {
    lf <- lf |>
      leaflet::addCircleMarkers(data = shape_data,
                                label = ~labels,
                                color = opts$colors,
                                radius = 3,
                                fillOpacity = 1)
  }
  if (shape_class == "SpatialPolygonsDataFrame") {

    pal <- leaflet::colorNumeric(rev(opts$colors),
                        domain = shape_data[[opts$var_num]])
    lf <- lf |>
      leaflet::addPolygons(data = shape_data,
                           label = ~labels,
                           stroke = FALSE,
                           fillOpacity = 1,
                           smoothFactor = 0.5,
                           fillColor = pal(shape_data@data[[opts$var_num]])
      )
  }

  lf

}
