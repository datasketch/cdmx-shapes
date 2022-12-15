#webshot::install_phantomjs()
library(dsmodules)
library(hgchmagic)
library(lfltmagic)
library(parmesan)
library(shiny)
library(shinypanels)

ui <- panelsPage(
  includeCSS("www/custom.css"),
  panel(title = " ",
        id = "azul",
        can_collapse = FALSE,
        width = 300,
        body =  div(
          uiOutput("controls")
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
          uiOutput("viz_view")
        )
  )
)


server <- function(input, output, session) {

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



