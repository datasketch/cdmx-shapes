#webshot::install_phantomjs()
library(cdmx.shapes)
library(dsmodules)
library(leaflet)
library(shiny)
library(shinypanels)

ui <- panelsPage(
  includeCSS("www/custom.css"),
  panel(title = " ",
        id = "azul",
        can_collapse = FALSE,
        width = 350,
        body =  div(
          div(class = "title-div-filters", "OPCIONES MAPA"),
          uiOutput("layers"),
          uiOutput("numeric_ui"),
          uiOutput("label_opts"),
          div(class = "title-div-filters", "AJUSTES ESTÉTICOS"),
          uiOutput("colors")
        ),
        footer =  tags$a(
          href="https://www.datasketch.co", target="blank",
          img(src= 'img/ds_logo.svg',
              align = "left", width = 130, height = 70))
  ),
  panel(title = " ",
        id = "naranja",
        can_collapse = FALSE,
        header_right = div(
          class = "head-viz",
          div(class = "viz-style",
              uiOutput("viz_icons")),
          uiOutput("downloads")
        ),
        body =  div(
         # verbatimTextOutput("debug"),
          leafletOutput("map_shape", height = 620)
        )
  )
)


server <- function(input, output, session) {


  # global info -------------------------------------------------------------

  readRenviron(".Renviron")
  urlInfo <- Sys.getenv("ckanUrl")

  par <- list(ckanConf = NULL)

  url_par <- reactive({
    shinyinvoer::url_params(par, session)
  })


  # read ckan info ----------------------------------------------------------

  info_url <- reactive({
    linkInfo <- url_par()$inputs$ckanConf
    if (is.null(linkInfo)) linkInfo <-  "cd29b08a-50a3-486a-9bea-12d745e2964c"
    cdmx.shapes:::read_ckan_info(url = urlInfo, linkInfo = linkInfo)
  })

  # read url from ckan ------------------------------------------------------

  shape_info <- reactive({
    req(info_url())
    url_shape <- info_url()$url
    unlink("down_shapes/", recursive = TRUE)
    #url_shape <- "https://datos-prueba.cdmx.gob.mx/dataset/05d66891-33f9-405c-b6a3-f29aff791c1c/resource/ace56b90-85b6-47ed-a9d6-acf413f61dda/download/ingreso_promedio_trimestral.zip"
    unzip_shape(url = url_shape, export_dir = "down_shapes")
  })


  # show layers to plot -----------------------------------------------------

  output$layers <- renderUI({
    req(shape_info)
    radioButtons("layer_id",
                 "Capa a visualizar",
                 shape_info()$shape_layer,
                 selected = shape_info()$shape_layer[1])
  })


  # read shape --------------------------------------------------------------

  shape_load <- reactive({
    req(shape_info())
    shape_layer <- input$layer_id
    if (is.null(shape_layer)) shape_layer <- shape_info()$shape_layer[1]
    suppressWarnings(
      shape <- read_shape(shape_dsn = shape_info()$shape_dsn,
                          shape_layer = shape_layer,
                          shape_file = shape_info()$shape_file)
    )
    shape
  })



  # read data from shape ----------------------------------------------------

  shape_fringe <- reactive({
    req(shape_load())
    cdmx.shapes::fringe_data(shape_load()@data)
  })


  # variables numericas a graficar
  numeric_var <- reactive({
    req(shape_fringe())
    if (class(shape_load())[1] == "SpatialPointsDataFrame") return()
    dic <- shape_fringe()$dic
    if (nrow(dic) == 0) return()
    dic$hdType[dic$id == "ano"] <- "Yea"
    dic$hdType[dic$id == "id"] <- "Uid"
    dic$hdType[dic$id == "cve_ent"] <- "___"
    dic$hdType[dic$id == "c_ingrtrim"] <- "___"
    dic <- dic |>
      dplyr::filter(hdType == "Num")
    if (nrow(dic) == 0) return()
    dic$label
  })


  output$numeric_ui <- renderUI({
    req(numeric_var())
    selectizeInput("numeric_id", "Variable numerica", numeric_var())
  })

  output$label_opts <- renderUI({
    req(shape_fringe())
    dic <-  shape_fringe()$dic
    if (nrow(dic) == 0) return()
    checkboxGroupInput("label_id",
                       "Informacion del tooltip",
                       choices = dic$label,
                       selected = dic$label)
  })

  palette_colors <- reactive({
    req(shape_load())
    pc <- cdmx.shapes:::colores_shape(class_shape = class(shape_load())[1])
    pc
  })


  output$colors <- renderUI({
    req(palette_colors())
    colores <- cdmx.shapes:::colors_print(palette_colors())
    shinyinvoer::radioButtonsInput("colors_id", label = "Colores", colores)
  })


  shape_to_plot <- reactive({
    req(shape_load())
    shape <- shape_load()
    label_id <- input$label_id
    if (!is.null(label_id)) {
      label_id <- intersect(label_id, names(shape@data))
      if (!identical(label_id, character())) {
        shape@data <- shape@data |>
          dplyr::mutate(labels = glue::glue(
            cdmx.shapes:::labels_map(nms = label_id)) %>%
              lapply(htmltools::HTML)
          )
      }
    } else {
      shape@data$labels <- NA
    }
    shape
  })


  output$map_shape <- renderLeaflet({
    req(shape_to_plot())
    req(palette_colors())
    req(input$colors_id)
    opts <- list(
      colors = palette_colors()[[input$colors_id]],
      var_num = input$numeric_id
    )
    plot_shapes(shape_to_plot(), opts = opts)
  })

  output$debug <- renderPrint({
    print(class(shape_load())[1])
  })


  output$viz_icons <- renderUI({
    suppressWarnings(
      shinyinvoer::buttonImageInput("viz_selection",
                                    " ",
                                    images = "map",
                                    tooltips = "Mapa",
                                    path = "viz_icons/",
                                    active = "map",
                                    imageStyle = list(shadow = TRUE,
                                                      borderColor = "#ffffff",
                                                      padding = "3px")
      )
    )
  })

}

shinyApp(ui, server)



