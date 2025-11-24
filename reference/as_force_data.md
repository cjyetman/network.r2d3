# Convert one of numerous data types to force_network's 'native' data format

The `force_network` function uses a 'native' data format that consists
of a...

## Usage

``` r
as_force_data(.data, ...)

# S3 method for class 'character'
as_force_data(.data, ...)

# S3 method for class 'data.frame'
as_force_data(.data, ...)

# S3 method for class 'igraph'
as_force_data(.data, ...)

# S3 method for class 'hclust'
as_force_data(.data, ...)

# S3 method for class 'dendrogram'
as_force_data(.data, ...)

# S3 method for class 'list'
as_force_data(.data, ...)
```

## Arguments

- .data:

  a force network description in one of numerous forms (see details).

- ...:

  other arguments that will be passed on to as_force_data

## Methods (by class)

- `as_force_data(character)`: Convert data found at a URL to an
  appropriate network data list

- `as_force_data(data.frame)`: Convert a data frame containing links
  data to an appropriate network data list

- `as_force_data(igraph)`: Convert an igraph object to an appropriate
  network data list

- `as_force_data(hclust)`: Convert a hclust object to an appropriate
  network data list

- `as_force_data(dendrogram)`: Convert a dendrogram object to an
  appropriate network data list

- `as_force_data(list)`: Convert a list object containg a links and a
  nodes data frame to an appropriate network data list
