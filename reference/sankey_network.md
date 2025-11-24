# Create an interactive sankey network plot in a htmlwidget

The `sankey_network` function creates an interactive sankey network plot
in a htmlwidget

## Usage

``` r
sankey_network(data, width = NULL, height = NULL, ..., viewer = "internal")
```

## Arguments

- data:

  a network description in one of numerous forms (see details)

- width, height:

  width and height of exported htmlwidget in pixels (single integer
  value; default == NULL)

- ...:

  other options (see details)

- viewer:

  whether to view the plot in the internal viewer or browser
