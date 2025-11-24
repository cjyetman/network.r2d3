# Create an interactive force network plot in a htmlwidget

The `force_network` function creates an interactive force network plot
in a htmlwidget

## Usage

``` r
force_network(data, width = NULL, height = NULL, ..., viewer = "internal")
```

## Arguments

- data:

  a tree network description in one of numerous forms (see details)

- width, height:

  width and height of exported htmlwidget in pixels (single integer
  value; default == NULL)

- ...:

  other options (see details)

- viewer:

  whether to view the plot in the internal viewer or browser
