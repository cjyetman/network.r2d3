sankey_explorer <- function(data) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("You must have {shiny} installed to use `sankey_explorer()`")
  }

  obj_name <- deparse(substitute(data))
  data <- as_sankey_data(data)

  ui <- shiny::fluidPage(
    shiny::inputPanel(
      shiny::selectInput(
        inputId = "nodeId",
        label = "nodeId:",
        choices = c(`(default) "id"` = "id", names(data$nodes)),
        selected = '(default) "id"'
      ),
      shiny::selectInput(
        inputId = "nodeGroup",
        label = "nodeGroup:",
        choices = c(`(default) "group"` = "group", names(data$nodes)),
        selected = '(default) "group"'
      ),
      shiny::selectInput(
        inputId = "nodeLabel",
        label = "nodeLabel:",
        choices = c(`(default) "id"` = "id", names(data$nodes)),
        selected = '(default) "id"'
      ),
      shiny::textInput(
        inputId = "nodeLabelFontFamily",
        label = "nodeLabelFontFamily:",
        value = "sans-serif",
        placeholder = '(default) "sans-serif"'
      ),
      shiny::numericInput(
        inputId = "nodeLabelFontSize",
        label = "nodeLabelFontSize:",
        value = 10,
        min = 1,
        max = 84,
        step = 1
      ),
      shiny::selectInput(
        inputId = "linkPath",
        label = "linkPath:",
        choices = c(`(default) "path"` = "path", names(data$links)),
        selected = "path"
      ),
      shiny::selectInput(
        inputId = "linkColor",
        label = "linkColor:",
        choices = c("source", "target", "source-target", "path"),
        selected = ""
      ),
      shiny::selectInput(
        inputId = "colorScheme",
        label = "colorScheme:",
        choices = c("schemeCategory10", "schemeAccent", "schemeDark2", "schemePaired", "schemePastel1", "schemePastel2", "schemeSet1", "schemeSet2", "schemeSet3", "schemeTableau10"),
        selected = ""
      ),
      shiny::sliderInput("iterations", label = "iterations:",
                  min = 0, max = 100, value = 6, step = 1),
      shiny::selectInput(
        inputId = "nodeAlign",
        label = "nodeAlign:",
        choices = c("sankeyJustify", "sankeyLeft", "sankeyRight", "sankeyCenter"),
        selected = "sankeyJustify"
      ),
      shiny::textInput(
        inputId = "tooltipLinkText",
        label = "tooltipLinkText:",
        value = 'd.source[nodeLabel] + " \u2192 " + d.target[nodeLabel] + "<br/>" + format(d.value)',
        placeholder = '(default) "d.source[nodeLabel] + " \u2192 " + d.target[nodeLabel] + "<br/>" + format(d.value)"'
      ),
      shiny::downloadButton("download_svg", "save SVG"),
      shiny::downloadButton("download_png", "save PNG")
    ),
    r2d3::d3Output("d3")
  )

  server <- function(input, output) {
    output$d3 <- r2d3::renderD3({
      sankey_network(
        data = data,
        nodeId = input$nodeId,
        nodeGroup = input$nodeGroup,
        nodeLabel = input$nodeLabel,
        nodeLabelFontFamily = input$nodeLabelFontFamily,
        nodeLabelFontSize = input$nodeLabelFontSize,
        linkPath = input$linkPath,
        linkColor = input$linkColor,
        colorScheme = input$colorScheme,
        iterations = input$iterations,
        nodeAlign = input$nodeAlign,
        tooltipLinkText = input$tooltipLinkText
      )
    })

    output$download_svg <- shiny::downloadHandler(
      filename = function() {
        paste0(obj_name, ".svg")
      },
      content = function(file) {
        sn <- sankey_network(
          data = data,
          nodeId = input$nodeId,
          nodeGroup = input$nodeGroup,
          nodeLabel = input$nodeLabel,
          nodeLabelFontFamily = input$nodeLabelFontFamily,
          nodeLabelFontSize = input$nodeLabelFontSize,
          linkPath = input$linkPath,
          linkColor = input$linkColor,
          colorScheme = input$colorScheme,
          iterations = input$iterations,
          nodeAlign = input$nodeAlign,
          tooltipLinkText = input$tooltipLinkText
        )
        save_as_svg(sn, file)
      }
    )

    output$download_png <- shiny::downloadHandler(
      filename = function() {
        paste0(obj_name, ".png")
      },
      content = function(file) {
        sn <- sankey_network(
          data = data,
          nodeId = input$nodeId,
          nodeGroup = input$nodeGroup,
          nodeLabel = input$nodeLabel,
          nodeLabelFontFamily = input$nodeLabelFontFamily,
          nodeLabelFontSize = input$nodeLabelFontSize,
          linkPath = input$linkPath,
          linkColor = input$linkColor,
          colorScheme = input$colorScheme,
          iterations = input$iterations,
          nodeAlign = input$nodeAlign,
          tooltipLinkText = input$tooltipLinkText
        )
        save_as_png(sn, file)
      }
    )
  }

  shiny::shinyApp(ui = ui, server = server)
}
