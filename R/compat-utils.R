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


colores_shape <- function(class_shape) {

  if (class_shape %in% c("SpatialLinesDataFrame", "SpatialPointsDataFrame")) {
    cd <-   list(
      palette_a = c("#1B5C51"),
      palette_b = c("#B48E5D"),
      palette_c = c("#0E709E"),
      palette_d = c("#253786"),
      palette_e = c("#9E2348"),
      palette_f = c("#B33718")
    )
  }

  if (class_shape == "SpatialPolygonsDataFrame") {
    cd <- list(
      palette_a = c("#1B5C51", "#4E786F", "#66887F", "#7E9992", "#96ACA5", "#AFBFBB", "#C8D4D1", "#E2EBE9"),
      palette_b = c("#B48E5D", "#C3A57D", "#CBB18E", "#D3BDA0", "#DCCAB2", "#E4D6C5", "#EDE3D7", "#F6F1EB"),
      palette_c = c("#0E709E", "#568BB2", "#709ABC", "#88A9C7", "#9FBAD2", "#B5CADD", "#CBDBE8", "#E0EDF3"),
      palette_d = c("#253786", "#52599C", "#696DA9", "#8182B6", "#999AC4", "#B1B1D2", "#CACADE", "#E1E2EB"),
      palette_e = c("#9E2348", "#B15267", "#BB6979", "#C6818D", "#D19AA3", "#DCB3B9", "#E8CCD1", "#F4E5E9"),
      palette_f = c("#B33718", "#C45633", "#CC6644", "#D47657", "#DD876B", "#E69880", "#EFAA96", "#F8BBAD")
    )
  }

  cd

}


colors_print <- function(palette_colors) {
  cd <- palette_colors
  lc <- purrr::map(names(cd), function(palette) {
    colors <- cd[[palette]]
    as.character( div(
      purrr::map(colors, function(color) {
        div(style=paste0("width: 20px; height: 20px; display: inline-block; background-color:", color, ";"))
      })
    ))
  })
  names(lc) <- names(cd)
  lc
}


menu_buttons <- function(ids = NULL, labels = NULL, ...) {
  if (is.null(ids)) stop("Please enter identifiers for each question")
  if (is.null(labels)) stop("Please enter labels for each question")

  df <- data.frame(id = ids, questions = labels)
  l <- purrr::map(1:nrow(df), function(z){
    shiny::actionButton(inputId = df[z,]$id, label = df[z,]$questions, class = "needed")
  })
  l[[1]] <- gsub("needed", "needed basic_active", l[[1]])
  l[[1]] <- htmltools::HTML(paste0(paste(l[[1]], collapse = '')))

  l
}
