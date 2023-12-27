// !preview r2d3 data = jsonlite::toJSON(data.frame(nodeId = LETTERS[1:7], parentId = c("", "A", "A", "B","B", "C", "C"), name = LETTERS[1:7], nodeSize = 8, nodeStroke = "steelblue", nodeColor = "green", nodeSymbol = "circle", nodeFont = "sans-serif", nodeFontSize = 18, textColor = "grey", textOpacity = 1, linkColor = "grey", linkWidth = "1.5px", stringsAsFactors = FALSE), auto_unbox = TRUE), d3_version = 4, options = list(treeType = 'tidy', direction = 'right', linkType = 'diagonal')


r2d3.onRender(function(data, svg, width, height, options) {

        var duration = 800;

        svg.selectAll("g").remove();

        const root = d3.stratify()
          .id(d => d.nodeId)
          .parentId(d => d.parentId)
          (data);

        function mouseover(d) {
          return eval(options.mouseover)
        }

        function mouseout(d) {
          return eval(options.mouseout)
        }

        function symbolgen(name) {
          name = name == 'undefined' ? 'Circle' : name;
          name = name.charAt(0).toUpperCase() + name.substr(1).toLowerCase();
          name = ["Circle", "Cross", "Diamond", "Square", "Star", "Triangle", "Wye"].indexOf(name) == -1 ? "Circle" : name;
          return d3.symbol().type(d3['symbol' + name]);
        }

        var directions = {
          "down": {
            tree: (options.treeType === "tidy" ? d3.tree() : d3.cluster()).size([width, height]),
            linkgen: (options.linkType === "diagonal" ?
                        d3.linkVertical().x(d => d.x).y(d => d.y)
                      :
                        (d) => d3.line().curve(d3.curveStepAfter)(Object.keys(d).map((key) => [d[key].x, d[key].y]))
            ),
            nodegen: d => "translate(" + d.x + "," + d.y + ")"
          },
          "left": {
            tree: (options.treeType === "tidy" ? d3.tree() : d3.cluster())
            .size([height, width]),
            linkgen: (options.linkType === "diagonal" ?
                        d3.linkHorizontal().x(d => width - d.y).y(d => d.x)
                      :
                        (d) => d3.line().curve(d3.curveStepBefore)(Object.keys(d).map((key) => [width - d[key].y, d[key].x]))
            ),
            nodegen: d => "translate(" + (width - d.y) + "," + d.x + ")"
          },
          "up": {
            tree: (options.treeType === "tidy" ? d3.tree() : d3.cluster()).size([width, height]),
            linkgen: (options.linkType === "diagonal" ?
                        d3.linkVertical().x(d => d.x).y(d => height - d.y)
                      :
                        (d) => d3.line().curve(d3.curveStepAfter)(Object.keys(d).map((key) => [d[key].x, height - d[key].y]))
            ),
            nodegen: d => "translate(" + d.x + "," + (height - d.y) + ")"
          },
          "right": {
            tree: (options.treeType === "tidy" ? d3.tree() : d3.cluster()).size([height, width - 100]),
            linkgen: (options.linkType === "diagonal" ?
                        d3.linkHorizontal().x(d => d.y).y(d => d.x)
                      :
                        (d) => d3.line().curve(d3.curveStepBefore)(Object.keys(d).map((key) => [d[key].y, d[key].x]))
            ),
            nodegen: d => "translate(" + d.y + "," + d.x + ")"
          },
          "radial": {
            tree: (options.treeType === "tidy" ? d3.tree() : d3.cluster())
              .size([2 * Math.PI, Math.min(width, height) / 2])
              .separation((a, b) => (a.parent == b.parent ? 1 : 2) / a.depth),
            linkgen: d3.linkRadial().angle(d => d.x).radius(d => d.y),
            nodegen: d => "translate(" + [(d.y = +d.y) * Math.cos(d.x -= Math.PI / 2), d.y * Math.sin(d.x)] + ")"
          }
        };

        // radial type needs to be centered on the canvas
        if (options.direction == "radial") {
          g = svg.append("g").attr("transform", "translate(" + (width / 2 + 40) + "," + (height / 2 + 90) + ")");
          root.x0 = height / 2;
          root.y0 = width / 2;
        } else {
          g = svg.append("g");
          root.x0 = height / 2;
          root.y0 = 0;
        }

        var tree = directions[options.direction].tree,
            linkgen = directions[options.direction].linkgen,
            nodegen = directions[options.direction].nodegen;

        var linkgrp = g.append("g").attr("class", "linkgrp");
        var nodegrp = g.append("g").attr("class", "nodegrp");

        update(root);

        function update(source) {
          var treeData = tree(root);

          if (treeData.descendants().reduce((a, b) => typeof b.data.height !== 'undefined' && a, true)) {
            var ymax = d3.max(treeData.descendants(), d => d.data.height || d.height);
            var ymin = d3.min(treeData.descendants(), d => d.data.height || d.height);
            heightToY = d3.scaleLinear().domain([ymax, ymin]).range([0, width]);
            treeData.eachAfter(d => d.y = heightToY(d.data.height || d.height));
          }

          var nodes = treeData.descendants(),
              links = treeData.links(nodes);

          // update the links
          var link = linkgrp.selectAll(".link")
            .data(links, d => d.target.id);

          // enter any new links at the parent's previous position
          var linkEnter = link.enter().insert("path", "g")
            .attr("class", "link")
            .style("fill", "none")
            .style("stroke", d => d.target.data.linkColor)
            .style("stroke-opacity", 0.4)
            .style("stroke-width", d => d.target.data.linkWidth)
            .attr("d", function(d) {
              var o = {x: source.x0, y: source.y0};
              return linkgen({source: o, target: o});
            })

          // transition links to their new position
          var linkUpdate = linkEnter.merge(link);
          linkUpdate.transition()
            .duration(duration)
            .attr("d", linkgen)

          // Transition exiting nodes to the parent's new position
          link.exit().transition()
            .duration(duration)
            .attr("d", function(d) {
            var o = {x: source.x, y: source.y};
            return linkgen({source: o, target: o});
          })
            .remove()

          var node = nodegrp.selectAll(".node").data(nodes, (d,i) => d.id || (d.id = ++i));

          nodeEnter = node.enter()
            .append("g")
            .attr("class", "node")
            .attr("transform", d => typeof source !== 'undefined' ? nodegen({x: source.x0, y: source.y0}) : nodegen(d))
            .on("click", click)
            .on("mouseover", mouseover)
            .on("mouseout", mouseout)
            .attr('cursor', d => d.children || d._children ? "pointer" : "default")

          nodeEnter.append("path")
            .style("fill", d => d._children ? d.data.nodeColor : "white")
            .style("opacity", 1e-6)
            .style("stroke", d => d.data.nodeStroke)
            .style("stroke-width", "1.5px")
            .attr("d", d => symbolgen(d.data.nodeSymbol).size(Math.pow(d.data.nodeSize, 2))())

          nodeEnter.append("text")
            .attr("transform", "rotate(" + options.textRotate + ")")
            .attr("x", d => d.children ? -6 : 6)
            .attr("text-anchor", d => d.children ? "end" : "start")
            .style("font-family", d => d.data.nodeFont)
            .style("font-size", "1px")
            .style("opacity", d => d.data.textOpacity)
            .style("fill", d => d.data.textColor)
            .text(d => d.data.name)

          var nodeUpdate = nodeEnter.merge(node);

          nodeUpdate.transition()
            .duration(duration)
            .attr("transform", nodegen)

          nodeUpdate.select("path")
            .transition()
            .duration(duration)
            .style("opacity", 1)
            .style("fill", d => d._children ? d.data.nodeColor : "white")

          nodeUpdate.select("text")
            .transition()
            .duration(duration)
            .style("font-size", d => d.data.nodeFontSize + "px")

          var nodeExit = node.exit();

          nodeExit.transition("exittransition")
            .duration(duration)
            .attr("transform", d => nodegen(source))
            .remove();

          nodeExit.select('path')
            .transition("exittransition")
            .duration(duration)
            .style('fill', 1e-6)
            .style('fill-opacity', 1e-6)
            .attr("d", d3.symbol().type(d3.symbolCircle).size(1e-6));

          nodeExit.select('text')
            .transition("exittransition")
            .duration(duration)
            .style('opacity', 1e-6)

          nodes.forEach(function(d){
            d.x0 = d.x;
            d.y0 = d.y;
          });
        }

        function click(d) {
          if (d.children) {
            d._children = d.children;
            d.children = null;
          } else {
            d.children = d._children;
            d._children = null;
          }
          update(d);
        }

});
