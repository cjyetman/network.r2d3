// !preview r2d3 data = jsonlite::toJSON(list(links = data.frame(source = c("A", "A"), target = c("B", "C"), value = c(10,5)), nodes = data.frame(id = c("A", "B", "C"), group = c("A", "B", "C")))), dependencies = "inst/lib/d3-sankey/d3-sankey.min.js", d3_version = 6, options = list(nodeLabel = "id", linkStrokeOpacity = 0.3, nodeLabelPadding = 6), container = "div", viewer = "internal"

div.append("svg");
const tooltip_div = div.append("div");

const svg = div.select("svg")
  .attr("width", width)
  .attr("height", height)
  .attr("viewBox", [0, 0, width, height])
  .attr("style", "max-width: 100%; height: auto;");

const sankey = d3.sankey();

r2d3.onRender(function(data, div, width, height, options) {

  const nodeId = options.nodeId ?? "id";
  const nodeLabel = options.nodeLabel ?? "name";
  const nodeAlign = options.nodeAlign ?? "sankeyJustify";
  const nodeWidth = options.nodeWidth ?? 24;
  const nodePadding = options.nodePadding ?? 8;
  const nodeGroup = options.nodeGroup ?? "group";
  const nodeSort = options.nodeSort ?? undefined;
  const iterations = options.iterations ?? 6;
  const colorScheme = options.colorScheme ?? "schemeCategory10";
  const linkColor = options.linkColor ?? "source-target";
  const linkSort = options.linkSort ?? undefined;
  const linkPath = options.linkPath ?? "path";
  const nodeLabelFontFamily = options.nodeLabelFontFamily ?? "sans-serif";
  const nodeLabelFontSize = options.nodeLabelFontSize ?? 10;
  const tooltipTransitionDuration = options.tooltipTransitionDuration ?? 200;
  const tooltipOpacity = options.tooltipOpacity ?? 0.8;
  const tooltipFontSize = options.tooltipFontSize ?? 12;
  const tooltipFontFamily = options.tooltipFontFamily ?? "sans-serif";
  const tooltipBorderRadius = options.tooltipBorderRadius ?? 4;

  const color = d3.scaleOrdinal(d3[colorScheme]);

  const widgetPadding = 40;

  const format = d3.format(",.0f");

  svg.selectAll("g").remove();

  sankey
    .nodeId(d => d[nodeId])
    .nodeAlign(d3[nodeAlign])
    .nodeWidth(nodeWidth)
    .nodePadding(nodePadding)
    .extent([[1, 5], [width - 1, height - 5]])
    .linkSort(eval(linkSort))
    .nodeSort(eval(nodeSort))
    .iterations(iterations);

  const {nodes, links} = sankey({
    nodes: data.nodes.map(d => Object.assign({}, d)),
    links: data.links.map(d => Object.assign({}, d))
  });

  // add tooltip div
  tooltip_div
    .attr("class", "tooltip")
    .style("opacity", 0)
    .style("position", "absolute")
    .style("text-align", "center")
    .style("padding", "10px")
    .style("font-size", tooltipFontSize + "px")
    .style("font-family", tooltipFontFamily)
    .style("background-color", "white")
    .style("color", "black")
    .style("border", "1px solid")
    .style("border-radius", tooltipBorderRadius + "px")
    .style("pointer-events", "none");

  function mouseover(event, d) {
    let tooltip_text = "";
    if (d.sourceLinks === undefined) {
      tooltip_text = d.source[nodeLabel] + " → " + d.target[nodeLabel] + "<br/>" + format(d.value);
    } else {
      tooltip_text = d[nodeLabel] + "<br/>" + format(d.value);
    }
    tooltip_div.transition()
      .duration(tooltipTransitionDuration)
      .style("opacity", tooltipOpacity);
    tooltip_div.html(tooltip_text)
      .style("left", event.pageX + "px")
      .style("top", (event.pageY - widgetPadding) + "px");
  }

  function mousemove(event) {
    tooltip_div
      .style("left", event.pageX + "px")
      .style("top", (event.pageY - widgetPadding) + "px");
  }

  function mouseout() {
    tooltip_div.transition()
      .duration(tooltipTransitionDuration)
      .style("opacity", 0);
  }

  // build nodes
  svg.append("g")
      .attr("stroke", "#000")
    .selectAll()
    .data(nodes)
    .join("rect")
      .attr("x", d => d.x0)
      .attr("y", d => d.y0)
      .attr("height", d => d.y1 - d.y0)
      .attr("width", d => d.x1 - d.x0)
      .attr("fill", d => color(d[nodeGroup]))
      .on("mouseover", mouseover)
      .on("mousemove", mousemove)
      .on("mouseout", mouseout);

  svg.append("g")
    .selectAll()
    .data(nodes)
    .join("text")
      .attr("x", d => d.x0 < width / 2 ? d.x1 + 6 : d.x0 - 6)
      .attr("y", d => (d.y1 + d.y0) / 2)
      .attr("dy", "0.35em")
      .attr("text-anchor", d => d.x0 < width / 2 ? "start" : "end")
      .text(d => d[nodeLabel])
      .style("font-size", nodeLabelFontSize + "px")
      .style("font-family", nodeLabelFontFamily);

  // build links
  const link = svg.append("g")
      .attr("fill", "none")
      .attr("stroke-opacity", 0.5)
    .selectAll()
    .data(links)
    .join("g")
      .style("mix-blend-mode", "multiply");

  if (linkColor === "source-target") {
    const gradient = link.append("linearGradient")
        .attr("id", (d, i) => (d.uid = `link-${i}`))
        .attr("gradientUnits", "userSpaceOnUse")
        .attr("x1", d => d.source.x1)
        .attr("x2", d => d.target.x0);
    gradient.append("stop")
        .attr("offset", "0%")
        .attr("stop-color", d => color(d.source[nodeGroup]));
    gradient.append("stop")
        .attr("offset", "100%")
        .attr("stop-color", d => color(d.target[nodeGroup]));
  }

  link.append("path")
    .attr("d", d3.sankeyLinkHorizontal())
    .attr("stroke", linkColor === "source-target" ? (d) => `url(#${d.uid})`
        : linkColor === "source" ? (d) => color(d.source[nodeGroup])
        : linkColor === "target" ? (d) => color(d.target[nodeGroup])
        : linkColor === "path" ? (d) => color(d[linkPath])
        : linkColor)
    .attr("stroke-width", d => Math.max(1, d.width))
    .on("mouseover", mouseover)
    .on("mousemove", mousemove)
    .on("mouseout", mouseout);

});
