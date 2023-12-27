#' Interactive `force_network` options explorer
#'
#' @param data a network description in one of numerous forms (see details)
#'
#' @description
#' An interactive shiny widget to explore the `force_network` options.
#'
#' @md
#'
#' @export

force_explorer <- function(data) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("You must have {shiny} installed to use `sankey_explorer()`")
  }

  obj_name <- deparse(substitute(data))
  data <- as_force_data(data)

  ui <- shiny::fluidPage(
    shiny::inputPanel(
      shiny::numericInput(
        inputId = "width",
        label = "width:",
        value = NULL,
        min = 1,
        max = 952,
        step = 1
      ),
      shiny::numericInput(
        inputId = "height",
        label = "height:",
        value = NULL,
        min = 1,
        max = 5000,
        step = 1
      ),
      shiny::numericInput(
        inputId = "node_size",
        label = "node_size:",
        value = 4,
        min = 1,
        max = 80,
        step = 1
      ),
      shiny::numericInput(
        inputId = "strength",
        label = "strength:",
        value = -300,
        min = -500,
        max = 80,
        step = 1
      ),
      shiny::numericInput(
        inputId = "distanceMin",
        label = "distanceMin:",
        value = 1,
        min = 1,
        max = 100,
        step = 1
      ),
      shiny::numericInput(
        inputId = "distanceMax",
        label = "distanceMax:",
        value = "Infinity",
        min = 1,
        max = 8000,
        step = 1
      ),
      shiny::checkboxInput(
        inputId = "draw_arrows",
        label = "draw_arrows:",
        value = FALSE
      ),
      shiny::checkboxInput(
        inputId = "solid_arrows",
        label = "solid_arrows:",
        value = TRUE
      ),
      shiny::numericInput(
        inputId = "arrow_length",
        label = "arrow_length:",
        value = 10,
        min = 1,
        max = 30,
        step = 1
      ),
      shiny::numericInput(
        inputId = "zoom_scale",
        label = "zoom_scale:",
        value = 0.5,
        min = 0,
        max = 10,
        step = 0.1
      ),
      shiny::checkboxInput(
        inputId = "plot_static",
        label = "plot_static:",
        value = FALSE
      ),
      shiny::downloadButton("download_png", "save PNG")
    ),
    r2d3::d3Output("d3")
  )

  server <- function(input, output) {
    output$d3 <- r2d3::renderD3({
      force_network(
        data = data,
        width = input$width,
        height = input$height,
        node_size = input$node_size,
        strength = input$strength,
        distanceMin = input$distanceMin,
        distanceMax = input$distanceMax,
        draw_arrows = input$draw_arrows,
        solid_arrows = input$solid_arrows,
        arrow_length = input$arrow_length,
        zoom_scale = input$zoom_scale,
        plot_static = input$plot_static
      )
    })

    output$download_png <- shiny::downloadHandler(
      filename = function() {
        paste0(obj_name, ".png")
      },
      content = function(file) {
        warning(input$width)
        plot <- force_network(
          data = data,
          width = input$width,
          height = input$height,
          node_size = input$node_size,
          strength = input$strength,
          distanceMin = input$distanceMin,
          distanceMax = input$distanceMax,
          draw_arrows = input$draw_arrows,
          solid_arrows = input$solid_arrows,
          arrow_length = input$arrow_length,
          zoom_scale = input$zoom_scale,
          plot_static = input$plot_static
        )
        save_as_png(plot, file)
      }
    )
  }

  shiny::shinyApp(ui = ui, server = server)
}