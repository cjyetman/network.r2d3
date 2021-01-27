# network.r2d3

<!-- badges: start -->
![dev tests](https://github.com/cjyetman/network.r2d3/workflows/dev%20tests/badge.svg)
<!-- badges: end -->

network.r2d3 makes interactive network charts in D3 leveraging [r2d3](https://rstudio.github.io/r2d3/)

It is intended to closely follow the functionality of [networkD3](https://christophergandrud.github.io/networkD3/), but with the following benefits:

1. leverage the benefits of `r2d3` versus including a version of D3 internally
2. use a better, more consistent API based on current standards in tidyverse
3. use transparent converters to enable easy usage of numerous data input types
4. use a testing infrastructure to aid in development

## Installation

You can install the dev version of network.r2d3 with:

``` r
devtools::install_github("cjyetman/network.r2d3")
```
