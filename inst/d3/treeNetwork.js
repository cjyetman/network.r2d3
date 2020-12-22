// !preview r2d3 reps <- 7, data = jsonlite::toJSON(data.frame(nodeId = LETTERS[1:7], parentId = c("", "A", "A", "B","B", "C", "C"), name = LETTERS[1:7], nodeSize = rep(8, reps), nodeStroke = rep("steelblue", reps), nodeColor = rep("green", reps), nodeSymbol = rep("circle", reps), nodeFont = rep("sans-serif", reps), nodeFontSize = rep(18, reps), textColor = rep("grey", reps), textOpacity =rep(1, reps), linkColor = rep("grey", reps), linkWidth = rep("1.5px", reps), stringsAsFactors = FALSE), auto_unbox = TRUE), d3_version = 4, options = list(treeType = 'tidy', direction = 'right', linkType = 'diagonal')



r2d3.onRender(function(data, svg, width, height, options) {

        // TESTING //
        //window.data = data;
        //window.options = options;
        /////////////

        var duration = 800;

        var root = d3.stratify()
        .id(function(d){ return d.nodeId; })
        .parentId(function(d){ return d.parentId; })
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
                        d3.linkVertical().x(function(d) { return d.x; }).y(function(d) { return d.y; })
                      :
                        function unobj(d) {
                          return d3.line().curve(d3.curveStepAfter)(Object.keys(d).map(function(key) { return [d[key].x, d[key].y]; }));
                        }
            ),
            nodegen: function(d) { return "translate(" + d.x + "," + d.y + ")"; }
          },
          "left": {
            tree: (options.treeType === "tidy" ? d3.tree() : d3.cluster())
            .size([height, width]),
            linkgen: (options.linkType === "diagonal" ?
                        d3.linkHorizontal()
                      .x(function(d) { return width - d.y; })
                      .y(function(d) { return d.x; })
                      :
                        function unobj(d) {
                          return d3.line().curve(d3.curveStepBefore)(Object.keys(d).map(function(key) { return [width - d[key].y, d[key].x]; }));
                        }),
            nodegen: function(d) { return "translate(" + (width - d.y) + "," + d.x + ")"; }
          },
          "up": {
            tree: (options.treeType === "tidy" ? d3.tree() : d3.cluster()).size([width, height]),
            linkgen: (options.linkType === "diagonal" ?
                        d3.linkVertical().x(function(d) { return d.x; }).y(function(d) { return height - d.y; })
                      :
                        function unobj(d) {
                          return d3.line().curve(d3.curveStepAfter)(Object.keys(d).map(function(key) { return [d[key].x, height - d[key].y]; }));
                        }
            ),
            nodegen: function(d) { return "translate(" + d.x + "," + (height - d.y) + ")"; }
          },
          "right": {
            tree: (options.treeType === "tidy" ? d3.tree() : d3.cluster()).size([height, width - 100]),
            linkgen: (options.linkType === "diagonal" ?
                        d3.linkHorizontal()
                      .x(function(d) { return d.y; })
                      .y(function(d) { return d.x; })
                      :
                        function unobj(d) {
                          return d3.line().curve(d3.curveStepBefore)(Object.keys(d).map(function(key) { return [d[key].y, d[key].x]; }));
                        }),
            nodegen: function(d) { return "translate(" + d.y + "," + d.x + ")"; }
          },
          "radial": {
            tree: (options.treeType === "tidy" ? d3.tree() : d3.cluster())
            .size([2 * Math.PI, Math.min(width,height) / 2])
            .separation(function(a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; }),
            linkgen: d3.linkRadial().angle(function(d) { return d.x; }).radius(function(d) { return d.y; }),
            nodegen: function(d) { return "translate(" + [(d.y = +d.y) * Math.cos(d.x -= Math.PI / 2), d.y * Math.sin(d.x)] + ")"; }
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

          if (treeData.descendants().reduce(function(a, b) { return typeof b.data.height !== 'undefined' && a; }, true)) {
            var ymax = d3.max(treeData.descendants(), function(d) { return d.data.height || d.height; });
            var ymin = d3.min(treeData.descendants(), function(d) { return d.data.height || d.height; });
            heightToY = d3.scaleLinear().domain([ymax, ymin]).range([0, width]);
            treeData.eachAfter(function(d) { d.y = heightToY(d.data.height || d.height); });
          }

          var nodes = treeData.descendants(),
          links = treeData.links(nodes);

          // TESTING //
          //window.nodes = nodes;
          //window.links = links;
          /////////////

          // update the links
          var link = linkgrp.selectAll(".link")
          .data(links, function(d) { return d.target.id; });

          // enter any new links at the parent's previous position
          var linkEnter = link.enter().insert("path", "g")
          .attr("class", "link")
          .style("fill", "none")
          .style("stroke", function(d){ return d.target.data.linkColor; })
          .style("stroke-opacity", 0.4)
          .style("stroke-width", function(d){ return d.target.data.linkWidth; })
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

          var node = nodegrp.selectAll(".node").data(nodes, function(d,i) { return d.id || (d.id = ++i); });

          nodeEnter = node.enter()
          .append("g")
          .attr("class", "node")
          .attr("transform", function(d){ return typeof source !== 'undefined' ? nodegen({x: source.x0, y: source.y0}) : nodegen(d); })
          .on("click", click)
          .on("mouseover", mouseover)
          .on("mouseout", mouseout)
          .attr('cursor', function(d){ return d.children || d._children ? "pointer" : "default"; })

          nodeEnter.append("path")
          .style("fill", function(d){ return d._children ? d.data.nodeStroke: 'white';})
          .style("opacity", 1e-6)
          .style("stroke", function(d){ return d.data.nodeStroke; })
          .style("stroke-width", "1.5px")
          .attr("d", function(d){ return symbolgen(d.data.nodeSymbol).size(Math.pow(d.data.nodeSize, 2))(); })

          nodeEnter.append("text")
          .attr("transform", "rotate(" + options.textRotate + ")")
          .attr("x", d => d.children ? -6 : 6)
          .attr("text-anchor", d => d.children ? "end" : "start")
          .style("font-family", function(d){ return d.data.nodeFont; })
          .style("font-size", "1px")
          .style("opacity", function(d){ return d.data.textOpacity; })
          .style("fill", function(d){ return d.data.textColor; })
          .text(function(d){ return d.data.name; })

          var nodeUpdate = nodeEnter.merge(node);

          nodeUpdate.transition()
          .duration(duration)
          .attr("transform", nodegen)

          nodeUpdate.select("path")
          .transition()
          .duration(duration)
          .style("opacity", 1)
          .style("fill", function(d){ return d._children ? d.data.nodeStroke : 'white'; })

          nodeUpdate.select("text")
          .transition()
          .duration(duration)
          .style("font-size", function(d){ return d.data.nodeFontSize + "px"; })

          var nodeExit = node.exit();

          nodeExit.transition("exittransition")
          .duration(duration)
          .attr("transform", function(d){ return nodegen(source); })
          .remove()

          nodeExit.select('path')
          .transition("exittransition")
          .duration(duration)
          .style('fill', 1e-6)
          .style('fill-opacity', 1e-6)
          .attr("d", d3.symbol().type(d3.symbolCircle).size(1e-6))

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
