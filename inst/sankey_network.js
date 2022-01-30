// !preview r2d3 data = jsonlite::toJSON(list(nodes=data.frame(id=c(0,1,2,3,4,5,6),name=c("node0","node1","node2","node3","node4","node5","node6"),group=c("grp1","grp1","grp2","grp2","grp2","grp3","grp3")),links=data.frame(source=c(0,1,1,1,0,2,2,3,5),target=c(2,2,3,5,4,3,4,4,6),value=c(2,2,2,2,2,2,2,4,4)))), dependencies = "inst/lib/d3-sankey/d3-sankey.min.js", d3_version = 6, width = 600, height = 300, options = list(linkStrokeOpacity=0.3,linkMixBlendMode="multiply",linkPath="d3.sankeyLinkHorizontal()",linkColor="source-target",nodeAlign="justify",nodeGroup="group",nodeWidth=15,nodePadding=10,nodeLabelPadding=6,nodeLabelFontFamily="sans-serif",nodeLabelFontSize=10,colors="d3.schemeCategory10"), viewer = "browser"

r2d3.onRender(function(data, svg, width, height, options) {
  let linkStrokeOpacity = options.linkStrokeOpacity;
  let linkMixBlendMode = options.linkMixBlendMode;
  let linkPath = eval(options.linkPath);
  let linkColor = options.linkColor;
  let nodeAlign = options.nodeAlign;
  let nodeGroup = options.nodeGroup;
  let nodeWidth = options.nodeWidth;
  let nodePadding = options.nodePadding;
  let nodeLabelPadding = options.nodeLabelPadding;
  let nodeLabelFontFamily = options.nodeLabelFontFamily;
  let nodeLabelFontSize = options.nodeLabelFontSize;
  let colors = eval(options.colors);

  const uid = `O-${Math.random().toString(16).slice(2)}`;

  nodeAlign = {
    left: d3.sankeyLeft,
    right: d3.sankeyRight,
    center: d3.sankeyCenter
  }[nodeAlign] ?? d3.sankeyJustify;

  const formatNumber = d3.format(",.0f");

  const color = d3.scaleOrdinal(colors);

  let sankey = d3.sankey()
    .nodeId(function id(d) { return d.id; })
    .nodeWidth(nodeWidth)
    .nodeAlign(nodeAlign)
    .nodePadding(nodePadding)
    .size([width, height])
    ;

  let sankeydata = sankey(data);
  let links = sankeydata.links;
  let nodes = sankeydata.nodes;

  // add in the links
  const link_slct = svg
    .append("g")
    .attr("fill", "none")
    .attr("stroke-opacity", linkStrokeOpacity)
    .selectAll("g")
    .data(links)
    .join("g")
    .style("mix-blend-mode", linkMixBlendMode)
    ;

  if (linkColor === "source-target") {
    link_slct.append("linearGradient")
      .attr("id", d => `${uid}-link-${d.index}`)
      .attr("gradientUnits", "userSpaceOnUse")
      .attr("x1", d => d.source.x1)
      .attr("x2", d => d.target.x0)
      .call(gradient => gradient.append("stop")
        .attr("offset", "0%")
        .attr("stop-color", d => color(d.source[nodeGroup]))
      )
      .call(gradient => gradient.append("stop")
        .attr("offset", "100%")
        .attr("stop-color", d => color(d.target[nodeGroup]))
      )
      ;
  }

  link_slct.append("path")
    .attr("d", linkPath)
    .attr("stroke", linkColor === "source-target" ? d => `url(#${uid}-link-${d.index})`
      : linkColor === "source" ? d => color(d.source[nodeGroup])
      : linkColor === "target" ? d => color(d.target[nodeGroup])
      : linkColor)
    .attr("stroke-width", ({width}) => Math.max(1, width))
    .append("title")
    .text(d => d.source.name + " → " + d.target.name + "\n" + formatNumber(d.value))
    ;

  const node_slct = svg.append("g")
    .selectAll(".node")
    .data(nodes)
    .join("rect")
    .attr("class", "node")
    .attr("x", d => d.x0)
    .attr("y", d => d.y0)
    .attr("height", d => d.y1 - d.y0)
    .attr("width", sankey.nodeWidth())
    .style("fill", d => d.color = color(d[nodeGroup]))
    .style("stroke", d => d3.rgb(d.color).darker(2))
    ;

  node_slct.append("title").text(d => d.name + "\n" + formatNumber(d.value));

  const nodeLabel_slct = svg.append("g")
    .attr("font-family", nodeLabelFontFamily)
    .attr("font-size", nodeLabelFontSize)
    .selectAll("text")
    .data(nodes)
    .join("text")
    .attr("x", d => d.x0 < width / 2 ? d.x1 + nodeLabelPadding : d.x0 - nodeLabelPadding)
    .attr("y", d => (d.y1 + d.y0) / 2)
    .attr("dy", "0.35em")
    .attr("text-anchor", d => d.x0 < width / 2 ? "start" : "end")
    .text(d => d.name)
    ;
});
