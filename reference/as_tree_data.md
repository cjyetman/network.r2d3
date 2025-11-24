# Convert one of numerous data types to tree_network's 'native' treenetdf form

The `tree_network` function uses a 'native' data format that consists of
a data frame with minimally 2 vectors/columns, one named `'nodeId'` and
one named `'parentId'`. Other columns in the data frame are also passed
on to the JavaScript code and attached to the elements in the D3
visualization so that they can potentially be accessed by other
JavaScript functions. This is an advantageous format because:

- it's an easy to use and understand R-like format

- a hierarchical network can be succinctly defined by a list of each
  unique node and its parent node

- since each row defines a unique node, additional columns can be added
  to add node-specific properties

- in a hierarchical network, every link/edge can be uniquely identified
  by the node which it leads to, therefore each link/edge can also be
  specifically addressed by adding columns for formatting of the
  incoming link

`as_tree_data` can convert from any of the following data types:

- `leafpathdf` (table)–`parent|parent|node`–`data.frame`

- hierarchical nested list (JSON)

- `hclust`

- `data.tree` Node

- igraph

- ape `phylo`

## Usage

``` r
as_tree_data(data, ...)

# S3 method for class 'character'
as_tree_data(data, ...)

# S3 method for class 'hclust'
as_tree_data(data, ...)

# S3 method for class 'list'
as_tree_data(data, children_name = "children", node_name = "name", ...)

# S3 method for class 'Node'
as_tree_data(data, ...)

# S3 method for class 'phylo'
as_tree_data(data, ...)

# S3 method for class 'tbl_graph'
as_tree_data(data, ...)

# S3 method for class 'igraph'
as_tree_data(data, root = "root", ...)

# S3 method for class 'data.frame'
as_tree_data(
  data,
  cols = NULL,
  df_type = "treenetdf",
  subset = names(data),
  root,
  ...
)
```

## Arguments

- data:

  a tree network description in one of numerous forms (see details).

- ...:

  other arguments that will be passed on to as_tree_data

- children_name:

  character specifying the name used for the list element that contains
  the childeren elements.

- node_name:

  character specifying the name used for the list element that contains
  the name of the node

- root:

  root name.

- cols:

  named character vector specifying the names of columns to be converted
  to the standard `treenetdf` names.

- df_type:

  character specifying which type of data frame to convert. Can be
  `treenetdf` or `leafpathdf`.

- subset:

  character vector specifying the names of the columns (in order) that
  should be used to define the hierarchy.

## Methods (by class)

- `as_tree_data(character)`: Convert JSON from URL to `treenetdf`

- `as_tree_data(hclust)`: Convert hclust objects to `treenetdf`

- `as_tree_data(list)`: Convert a nested list to `treenetdf`

- `as_tree_data(Node)`: data.tree to `treenetdf`

- `as_tree_data(phylo)`: Phylo tree to `treenetdf`

- `as_tree_data(tbl_graph)`: tbl_graph_to_treenetdf

- `as_tree_data(igraph)`: Convert igraph tree to `treenetdf`

- `as_tree_data(data.frame)`: Convert a data.frame to a `treenetdf`

## Examples

``` r
links <- read.csv(header = TRUE, stringsAsFactors = FALSE, text = '
                   source,target,name
                   1,,one
                   2,1,two
                   3,1,three
                   4,1,four
                   5,2,five
                   6,2,six
                   7,2,seven
                   8,6,eight')

 # Convert data
 as_tree_data(links, cols = c(nodeId = 'source', parentId = 'target'))
#> # A tibble: 8 × 3
#>   nodeId parentId name 
#>    <int>    <int> <chr>
#> 1      1       NA one  
#> 2      2        1 two  
#> 3      3        1 three
#> 4      4        1 four 
#> 5      5        2 five 
#> 6      6        2 six  
#> 7      7        2 seven
#> 8      8        6 eight
```
