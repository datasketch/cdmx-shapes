#webshot::install_phantomjs()
library(cdmx.shapes)
library(dsmodules)
library(hgchmagic)
library(lfltmagic)
library(shiny)
library(shinypanels)

ui <- panelsPage(
  includeCSS("www/custom.css"),
  panel(title = " ",
        id = "azul",
        can_collapse = FALSE,
        width = 300,
        body =  div(
          uiOutput("layers"),
          uiOutput("numeric_ui"),
          uiOutput("label_opts")
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
          verbatimTextOutput("debug")
          #uiOutput("viz_view")
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


  output$debug <- renderPrint({
    numeric_var()
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



