#' @export
run_app <- function(){
    app_file <- system.file("cdmx-shapes-app/app.R", package = "cdmx.shapes")
  shiny::runApp(app_file, port = 3838)
}
