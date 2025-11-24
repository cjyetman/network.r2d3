# Create an interactive tree network plot in an htmlwidget

The `tree_network` function creates an interactive tree network plot in
an htmlwidget

## Usage

``` r
tree_network(
  data,
  width = NULL,
  height = NULL,
  treeType = "tidy",
  direction = "right",
  linkType = "diagonal",
  ...,
  viewer = "internal"
)
```

## Arguments

- data:

  a tree network description in one of numerous forms (see details)

- width, height:

  width and height of exported htmlwidget in pixels (single integer
  value; default == NULL)

- treeType:

  type of tree; one of "tidy" or "cluster" (see details) (default ==
  "tidy")

- direction:

  direction toward which the tree grows; one of "right", "left", "down",
  or "up" (see details) (default == "right")

- linkType:

  type on link shape; one of "diagonal" or "elbow" (see details)
  (default == "diagonal")

- ...:

  other options (see details)

- viewer:

  whether to view the plot in the internal viewer or browser

## Examples

``` r
treedf <- data.frame(nodeId = LETTERS[1:7],
                     parentId = c("", "A", "A", "B", "B", "C", "C"),
                     name = LETTERS[1:7],
                     stringsAsFactors = FALSE)
tree_network(treedf)

{"x":{"data":[{"nodeId":"A","parentId":"","name":"A","nodeSize":10,"nodeStroke":"steelblue","nodeColor":"steelblue","nodeSymbol":"circle","nodeFont":"sans-serif","nodeFontSize":12,"textColor":"grey","textOpacity":1,"linkColor":"grey","linkWidth":"1.5px"},{"nodeId":"B","parentId":"A","name":"B","nodeSize":10,"nodeStroke":"steelblue","nodeColor":"steelblue","nodeSymbol":"circle","nodeFont":"sans-serif","nodeFontSize":12,"textColor":"grey","textOpacity":1,"linkColor":"grey","linkWidth":"1.5px"},{"nodeId":"C","parentId":"A","name":"C","nodeSize":10,"nodeStroke":"steelblue","nodeColor":"steelblue","nodeSymbol":"circle","nodeFont":"sans-serif","nodeFontSize":12,"textColor":"grey","textOpacity":1,"linkColor":"grey","linkWidth":"1.5px"},{"nodeId":"D","parentId":"B","name":"D","nodeSize":10,"nodeStroke":"steelblue","nodeColor":"steelblue","nodeSymbol":"circle","nodeFont":"sans-serif","nodeFontSize":12,"textColor":"grey","textOpacity":1,"linkColor":"grey","linkWidth":"1.5px"},{"nodeId":"E","parentId":"B","name":"E","nodeSize":10,"nodeStroke":"steelblue","nodeColor":"steelblue","nodeSymbol":"circle","nodeFont":"sans-serif","nodeFontSize":12,"textColor":"grey","textOpacity":1,"linkColor":"grey","linkWidth":"1.5px"},{"nodeId":"F","parentId":"C","name":"F","nodeSize":10,"nodeStroke":"steelblue","nodeColor":"steelblue","nodeSymbol":"circle","nodeFont":"sans-serif","nodeFontSize":12,"textColor":"grey","textOpacity":1,"linkColor":"grey","linkWidth":"1.5px"},{"nodeId":"G","parentId":"C","name":"G","nodeSize":10,"nodeStroke":"steelblue","nodeColor":"steelblue","nodeSymbol":"circle","nodeFont":"sans-serif","nodeFontSize":12,"textColor":"grey","textOpacity":1,"linkColor":"grey","linkWidth":"1.5px"}],"type":"json","container":"svg","options":{"treeType":"tidy","direction":"right","linkType":"diagonal"},"script":"var d3Script = function(d3, r2d3, data, svg, width, height, options, theme, console) {\nthis.d3 = d3;\n\nsvg = d3.select(svg.node());\n/* R2D3 Source File:  /home/runner/work/_temp/Library/network.r2d3/tree_network.js */\n// !preview r2d3 data = jsonlite::toJSON(data.frame(nodeId = LETTERS[1:7], parentId = c(\"\", \"A\", \"A\", \"B\",\"B\", \"C\", \"C\"), name = LETTERS[1:7], nodeSize = 8, nodeStroke = \"steelblue\", nodeColor = \"green\", nodeSymbol = \"circle\", nodeFont = \"sans-serif\", nodeFontSize = 18, textColor = \"grey\", textOpacity = 1, linkColor = \"grey\", linkWidth = \"1.5px\", stringsAsFactors = FALSE), auto_unbox = TRUE), d3_version = 4, options = list(treeType = 'tidy', direction = 'right', linkType = 'diagonal')\n\n\nr2d3.onRender(function(data, svg, width, height, options) {\n\n        var duration = 800;\n\n        svg.selectAll(\"g\").remove();\n\n        const root = d3.stratify()\n          .id(d => d.nodeId)\n          .parentId(d => d.parentId)\n          (data);\n\n        function mouseover(d) {\n          return eval(options.mouseover)\n        }\n\n        function mouseout(d) {\n          return eval(options.mouseout)\n        }\n\n        function symbolgen(name) {\n          name = name == 'undefined' ? 'Circle' : name;\n          name = name.charAt(0).toUpperCase() + name.substr(1).toLowerCase();\n          name = [\"Circle\", \"Cross\", \"Diamond\", \"Square\", \"Star\", \"Triangle\", \"Wye\"].indexOf(name) == -1 ? \"Circle\" : name;\n          return d3.symbol().type(d3['symbol' + name]);\n        }\n\n        var directions = {\n          \"down\": {\n            tree: (options.treeType === \"tidy\" ? d3.tree() : d3.cluster()).size([width, height]),\n            linkgen: (options.linkType === \"diagonal\" ?\n                        d3.linkVertical().x(d => d.x).y(d => d.y)\n                      :\n                        (d) => d3.line().curve(d3.curveStepAfter)(Object.keys(d).map((key) => [d[key].x, d[key].y]))\n            ),\n            nodegen: d => \"translate(\" + d.x + \",\" + d.y + \")\"\n          },\n          \"left\": {\n            tree: (options.treeType === \"tidy\" ? d3.tree() : d3.cluster())\n            .size([height, width]),\n            linkgen: (options.linkType === \"diagonal\" ?\n                        d3.linkHorizontal().x(d => width - d.y).y(d => d.x)\n                      :\n                        (d) => d3.line().curve(d3.curveStepBefore)(Object.keys(d).map((key) => [width - d[key].y, d[key].x]))\n            ),\n            nodegen: d => \"translate(\" + (width - d.y) + \",\" + d.x + \")\"\n          },\n          \"up\": {\n            tree: (options.treeType === \"tidy\" ? d3.tree() : d3.cluster()).size([width, height]),\n            linkgen: (options.linkType === \"diagonal\" ?\n                        d3.linkVertical().x(d => d.x).y(d => height - d.y)\n                      :\n                        (d) => d3.line().curve(d3.curveStepAfter)(Object.keys(d).map((key) => [d[key].x, height - d[key].y]))\n            ),\n            nodegen: d => \"translate(\" + d.x + \",\" + (height - d.y) + \")\"\n          },\n          \"right\": {\n            tree: (options.treeType === \"tidy\" ? d3.tree() : d3.cluster()).size([height, width - 100]),\n            linkgen: (options.linkType === \"diagonal\" ?\n                        d3.linkHorizontal().x(d => d.y).y(d => d.x)\n                      :\n                        (d) => d3.line().curve(d3.curveStepBefore)(Object.keys(d).map((key) => [d[key].y, d[key].x]))\n            ),\n            nodegen: d => \"translate(\" + d.y + \",\" + d.x + \")\"\n          },\n          \"radial\": {\n            tree: (options.treeType === \"tidy\" ? d3.tree() : d3.cluster())\n              .size([2 * Math.PI, Math.min(width, height) / 2])\n              .separation((a, b) => (a.parent == b.parent ? 1 : 2) / a.depth),\n            linkgen: d3.linkRadial().angle(d => d.x).radius(d => d.y),\n            nodegen: d => \"translate(\" + [(d.y = +d.y) * Math.cos(d.x -= Math.PI / 2), d.y * Math.sin(d.x)] + \")\"\n          }\n        };\n\n        // radial type needs to be centered on the canvas\n        if (options.direction == \"radial\") {\n          g = svg.append(\"g\").attr(\"transform\", \"translate(\" + (width / 2 + 40) + \",\" + (height / 2 + 90) + \")\");\n          root.x0 = height / 2;\n          root.y0 = width / 2;\n        } else {\n          g = svg.append(\"g\");\n          root.x0 = height / 2;\n          root.y0 = 0;\n        }\n\n        var tree = directions[options.direction].tree,\n            linkgen = directions[options.direction].linkgen,\n            nodegen = directions[options.direction].nodegen;\n\n        var linkgrp = g.append(\"g\").attr(\"class\", \"linkgrp\");\n        var nodegrp = g.append(\"g\").attr(\"class\", \"nodegrp\");\n\n        update(root);\n\n        function update(source) {\n          var treeData = tree(root);\n\n          if (treeData.descendants().reduce((a, b) => typeof b.data.height !== 'undefined' && a, true)) {\n            var ymax = d3.max(treeData.descendants(), d => d.data.height || d.height);\n            var ymin = d3.min(treeData.descendants(), d => d.data.height || d.height);\n            heightToY = d3.scaleLinear().domain([ymax, ymin]).range([0, width]);\n            treeData.eachAfter(d => d.y = heightToY(d.data.height || d.height));\n          }\n\n          var nodes = treeData.descendants(),\n              links = treeData.links(nodes);\n\n          // update the links\n          var link = linkgrp.selectAll(\".link\")\n            .data(links, d => d.target.id);\n\n          // enter any new links at the parent's previous position\n          var linkEnter = link.enter().insert(\"path\", \"g\")\n            .attr(\"class\", \"link\")\n            .style(\"fill\", \"none\")\n            .style(\"stroke\", d => d.target.data.linkColor)\n            .style(\"stroke-opacity\", 0.4)\n            .style(\"stroke-width\", d => d.target.data.linkWidth)\n            .attr(\"d\", function(d) {\n              var o = {x: source.x0, y: source.y0};\n              return linkgen({source: o, target: o});\n            })\n\n          // transition links to their new position\n          var linkUpdate = linkEnter.merge(link);\n          linkUpdate.transition()\n            .duration(duration)\n            .attr(\"d\", linkgen)\n\n          // Transition exiting nodes to the parent's new position\n          link.exit().transition()\n            .duration(duration)\n            .attr(\"d\", function(d) {\n            var o = {x: source.x, y: source.y};\n            return linkgen({source: o, target: o});\n          })\n            .remove()\n\n          var node = nodegrp.selectAll(\".node\").data(nodes, (d,i) => d.id || (d.id = ++i));\n\n          nodeEnter = node.enter()\n            .append(\"g\")\n            .attr(\"class\", \"node\")\n            .attr(\"transform\", d => typeof source !== 'undefined' ? nodegen({x: source.x0, y: source.y0}) : nodegen(d))\n            .on(\"click\", click)\n            .on(\"mouseover\", mouseover)\n            .on(\"mouseout\", mouseout)\n            .attr('cursor', d => d.children || d._children ? \"pointer\" : \"default\")\n\n          nodeEnter.append(\"path\")\n            .style(\"fill\", d => d._children ? d.data.nodeColor : \"white\")\n            .style(\"opacity\", 1e-6)\n            .style(\"stroke\", d => d.data.nodeStroke)\n            .style(\"stroke-width\", \"1.5px\")\n            .attr(\"d\", d => symbolgen(d.data.nodeSymbol).size(Math.pow(d.data.nodeSize, 2))())\n\n          nodeEnter.append(\"text\")\n            .attr(\"transform\", \"rotate(\" + options.textRotate + \")\")\n            .attr(\"x\", d => d.children ? -6 : 6)\n            .attr(\"text-anchor\", d => d.children ? \"end\" : \"start\")\n            .style(\"font-family\", d => d.data.nodeFont)\n            .style(\"font-size\", \"1px\")\n            .style(\"opacity\", d => d.data.textOpacity)\n            .style(\"fill\", d => d.data.textColor)\n            .text(d => d.data.name)\n\n          var nodeUpdate = nodeEnter.merge(node);\n\n          nodeUpdate.transition()\n            .duration(duration)\n            .attr(\"transform\", nodegen)\n\n          nodeUpdate.select(\"path\")\n            .transition()\n            .duration(duration)\n            .style(\"opacity\", 1)\n            .style(\"fill\", d => d._children ? d.data.nodeColor : \"white\")\n\n          nodeUpdate.select(\"text\")\n            .transition()\n            .duration(duration)\n            .style(\"font-size\", d => d.data.nodeFontSize + \"px\")\n\n          var nodeExit = node.exit();\n\n          nodeExit.transition(\"exittransition\")\n            .duration(duration)\n            .attr(\"transform\", d => nodegen(source))\n            .remove();\n\n          nodeExit.select('path')\n            .transition(\"exittransition\")\n            .duration(duration)\n            .style('fill', 1e-6)\n            .style('fill-opacity', 1e-6)\n            .attr(\"d\", d3.symbol().type(d3.symbolCircle).size(1e-6));\n\n          nodeExit.select('text')\n            .transition(\"exittransition\")\n            .duration(duration)\n            .style('opacity', 1e-6)\n\n          nodes.forEach(function(d){\n            d.x0 = d.x;\n            d.y0 = d.y;\n          });\n        }\n\n        function click(d) {\n          if (d.children) {\n            d._children = d.children;\n            d.children = null;\n          } else {\n            d.children = d._children;\n            d._children = null;\n          }\n          update(d);\n        }\n\n});\n};","style":null,"version":4,"theme":{"default":{"background":"#FFFFFF","foreground":"#000000"},"runtime":null},"useShadow":true},"evals":[],"jsHooks":[]}
```
