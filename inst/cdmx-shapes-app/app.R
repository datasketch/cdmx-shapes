#webshot::install_phantomjs()
library(cdmx.shapes)
library(dsmodules)
library(leaflet)
library(shiny)
library(shinybusy)
library(shinypanels)
library(tidyr)

ui <- panelsPage(
  includeCSS("www/custom.css"),
  tags$head(tags$script(src="handlers.js")),
  shinybusy::busy_start_up(
    loader = tags$img(
      src = "img/loading_gris.gif",
      width = 100),
    mode = "auto",
    color = "#435b69",
    background = "#FFF"),
  shinypanels::modal(id = 'modal_download',
                     title = " ",
                     fullscreen = TRUE,
                     id_title = "down-title",
                     id_content = "tab-content-modal",
                     id_wrapper = "tab-modal-down",
                     div( div(class = "tab-head-modal",
                              uiOutput("menu_modal")),
                          div(class = "tab-body-modal",
                              uiOutput("down_index")))
  ),
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
        header_right = div(style = "display: flex;align-items: center;",
                           # uiOutput("viz_icons"),
                           p(class = "app-version","Versión Beta"),
                           div(class = 'inter-container', style = "margin-right: 3%; margin-left: 3%;",
                               actionButton(inputId ='fs', "Fullscreen", onclick = "gopenFullscreen();")
                           ),
                           div(class='second-container',
                               actionButton("descargas", "Descargas", icon = icon("download"), width = "150px")
                           )
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
  url_info <- Sys.getenv("ckanUrl")

  par <- list(ckanConf = NULL)

  url_par <- reactive({
    shinyinvoer::url_params(par, session)
  })


  # read ckan info ----------------------------------------------------------

  info_url <- reactive({
    linkInfo <- url_par()$inputs$ckanConf
    if (is.null(linkInfo)) linkInfo <-  "cd29b08a-50a3-486a-9bea-12d745e2964c"
    cdmx.shapes:::read_ckan_info(url = url_info, linkInfo = linkInfo)
  })


  dic_ckan <- reactive({
    req(info_url())
    cdmx.shapes:::read_ckan_dic(url = url_info, info_url()$package_id)
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


  map_down <- reactive({
    req(shape_to_plot())
    req(palette_colors())
    req(input$colors_id)
    opts <- list(
      colors = palette_colors()[[input$colors_id]],
      var_num = input$numeric_id
    )
    plot_shapes(shape_to_plot(), opts = opts)
  })

  output$map_shape <- renderLeaflet({
   req(map_down())
    map_down()
  })




  # downloads ---------------------------------------------------------------

  observeEvent(input$descargas, {
    shinypanels::showModal("modal_download")
  })

  output$menu_modal <- renderUI({
    cdmx.shapes:::menu_buttons(ids = c("datos_dw", "viz_dw", "api_dw"),
                               labels = c("Base de datos", "Gráfica", "API"))
  })


  params_markdown <- reactive({
    req(map_down())
    req(info_url())
    list(viz = reactive(map_down()),
         title = gsub("\\*", "\\\\*",info_url()$name),
         subtitle = info_url()$resource_subtitle,
         fuentes =   paste0("<span style='font-weight:700;'>Fuente: </span>", dic_ckan$listCaptions$label, "<br/>",
                            tags$a(href= paste0("https://datos.cdmx.gob.mx/organization/", dic_ckan$listCaptions$id),
                                   paste0("https://datos.cdmx.gob.mx/organization/", dic_ckan$listCaptions$id), target="_blank"
                            )
         )
    )
  })

  output$debug <- renderPrint({
    print(class(shape_load())[1])
  })



  # output$viz_icons <- renderUI({
  #   suppressWarnings(
  #     shinyinvoer::buttonImageInput("viz_selection",
  #                                   " ",
  #                                   images = "map",
  #                                   tooltips = "Mapa",
  #                                   path = "viz_icons/",
  #                                   active = "map",
  #                                   imageStyle = list(shadow = TRUE,
  #                                                     borderColor = "#ffffff",
  #                                                     padding = "3px")
  #     )
  #   )
  # })

}

shinyApp(ui, server)



