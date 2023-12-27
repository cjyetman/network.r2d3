#' Interactive `tree_network` options explorer
#'
#' @param data a tree network description in one of numerous forms (see details)
#'
#' @description
#' An interactive shiny widget to explore the `tree_network` options.
#'
#' @md
#'
#' @export

tree_explorer <- function(data) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("You must have {shiny} installed to use `sankey_explorer()`")
  }

  obj_name <- deparse(substitute(data))
  data <- as_tree_data(data)

  ui <- shiny::fluidPage(
    shiny::inputPanel(
      shiny::numericInput(
        inputId = "width",
        label = "width:",
        value = 952,
        min = 1,
        max = 952,
        step = 1
      ),
      shiny::numericInput(
        inputId = "height",
        label = "height:",
        value = 500,
        min = 1,
        max = 5000,
        step = 1
      ),
      shiny::selectInput(
        inputId = "treeType",
        label = "treeType:",
        choices = c(`tidy [default]` = "tidy", "cluster"),
        selected = "tidy [default]"
      ),
      shiny::selectInput(
        inputId = "direction",
        label = "direction:",
        choices = c(`right [default]` = "right", "left", "down", "up", "radial"),
        selected = "right [default]"
      ),
      shiny::selectInput(
        inputId = "linkType",
        label = "linkType:",
        choices = c(`diagonal [default]` = "diagonal", "elbow"),
        selected = "diagonal [default]"
      ),
      shiny::numericInput(
        inputId = "nodeSize",
        label = "nodeSize:",
        value = 10,
        min = 1,
        max = 84,
        step = 1
      ),
      shiny::textInput(
        inputId = "nodeStroke",
        label = "nodeStroke:",
        value = "steelblue",
        placeholder = "steelblue [default]"
      ),
      shiny::textInput(
        inputId = "nodeColor",
        label = "nodeColor:",
        value = "steelblue",
        placeholder = "steelblue [default]"
      ),
      shiny::selectInput(
        inputId = "nodeSymbol",
        label = "nodeSymbol:",
        choices = c(`Circle [default]` = "Circle", "Cross", "Diamond", "Square", "Star", "Triangle", "Wye"),
        selected = "Circle"
      ),
      shiny::textInput(
        inputId = "nodeFont",
        label = "nodeFont:",
        value = "sans-serif",
        placeholder = "sans-serif [default]"
      ),
      shiny::numericInput(
        inputId = "nodeFontSize",
        label = "nodeFontSize:",
        value = 12,
        min = 1,
        max = 84,
        step = 1
      ),
      shiny::textInput(
        inputId = "textColor",
        label = "textColor:",
        value = "grey",
        placeholder = "grey [default]"
      ),
      shiny::numericInput(
        inputId = "textOpacity",
        label = "textOpacity:",
        value = 1,
        min = 0,
        max = 1,
        step = 0.1
      ),
      shiny::textInput(
        inputId = "linkColor",
        label = "linkColor:",
        value = "grey",
        placeholder = "grey [default]"
      ),
      shiny::numericInput(
        inputId = "linkWidth",
        label = "linkWidth (in pixels):",
        value = 1.5,
        min = 0,
        max = 15,
        step = 0.5
      ),
      shiny::downloadButton("download_svg", "save SVG"),
      shiny::downloadButton("download_png", "save PNG")
    ),
    r2d3::d3Output("d3")
  )

  server <- function(input, output) {
    output$d3 <- r2d3::renderD3({
      tree_network(
        data = data,
        width = input$width,
        height = input$height,
        treeType = input$treeType,
        direction = input$direction,
        linkType = input$linkType,
        nodeSize = input$nodeSize,
        nodeStroke = input$nodeStroke,
        nodeColor = input$nodeColor,
        nodeSymbol = input$nodeSymbol,
        nodeFont = input$nodeFont,
        nodeFontSize = input$nodeFontSize,
        textColor = input$textColor,
        textOpacity = input$textOpacity,
        linkColor = input$linkColor,
        linkWidth = input$linkWidth
      )
    })

    output$download_svg <- shiny::downloadHandler(
      filename = function() {
        paste0(obj_name, ".svg")
      },
      content = function(file) {
        warning(obj_name)
        plot <- tree_network(
          data = data,
          width = input$width,
          height = input$height,
          treeType = input$treeType,
          direction = input$direction,
          linkType = input$linkType,
          nodeSize = input$nodeSize,
          nodeStroke = input$nodeStroke,
          nodeColor = input$nodeColor,
          nodeSymobl = input$nodeSymobl,
          nodeFont = input$nodeFont,
          textColor = input$textColor,
          textOpacity = input$textOpacity,
          linkColor = input$linkColor,
          linkWidth = input$linkWidth
        )
        save_as_svg(plot, file)
      }
    )

    output$download_png <- shiny::downloadHandler(
      filename = function() {
        paste0(obj_name, ".png")
      },
      content = function(file) {
        plot <- tree_network(
          data = data,
          width = input$width,
          height = input$height,
          treeType = input$treeType,
          direction = input$direction,
          linkType = input$linkType,
          nodeSize = input$nodeSize,
          nodeStroke = input$nodeStroke,
          nodeColor = input$nodeColor,
          nodeSymobl = input$nodeSymobl,
          nodeFont = input$nodeFont,
          textColor = input$textColor,
          textOpacity = input$textOpacity,
          linkColor = input$linkColor,
          linkWidth = input$linkWidth
        )
        save_as_png(plot, file)
      }
    )
  }

  shiny::shinyApp(ui = ui, server = server)
}
