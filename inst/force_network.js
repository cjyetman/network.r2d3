// !preview r2d3 data = jsonlite::read_json('test_data/marvel3.json'), d3_version = 4, container = "canvas", options = list()

// https://bl.ocks.org/mbostock/ad70335eeef6d167bc36fd3c04378048
// https://bl.ocks.org/mbostock/b418a040bb28295e4a78581fe8e269d1

var node_color = eval(options.node_color) || d3.scaleOrdinal(d3.schemeCategory10),
    node_size = options.node_size || 4,
    link_color = options.link_color || "grey",
    strength = options.strength || -300,
    distanceMin = options.distanceMin || 1,
    distanceMax = options.distanceMax || Infinity,
    draw_arrows = options.draw_arrows || false,
    solid_arrows = options.solid_arrows || true,
    arrow_length = options.arrow_length || 10,
    zoom_scale = options.zoom_scale || 0.5,
    plot_static = options.plot_static || false == 1 ? true : false;

var canvas_node = canvas.node(),
    context = canvas_node.getContext("2d"),
    width = canvas_node.width,
    height = canvas_node.height;

var simulation = d3.forceSimulation(data.nodes)
    .force("link", d3.forceLink(data.links).id(function(d) { return d.id; }))
    .force("charge", d3.forceManyBody().strength(strength).distanceMin(distanceMin).distanceMax(distanceMax))
    .force("center", d3.forceCenter(width / 2, height / 2));

if (plot_static) {
  simulation.stop();

  for (var i = 0, n = Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
    simulation.tick();
  }
  ticked();

} else {
  simulation.on("tick", ticked);
}


/*
d3.select(canvas_node)
    .call(d3.drag()
        .container(canvas_node)
        .subject(dragsubject)
        .on("start", dragstarted)
        .on("drag", dragged)
        .on("end", dragended));
*/

// zoom
d3.select(canvas_node)
    .call(d3.zoom().scaleExtent([1 / 5, 50]).on("zoom", zoomed));

//drawPoints(d3.zoomIdentity);

function zoomed() {
  ticked(d3.event.transform);
}

function ticked(transform) {
  // clear canvas
  context.clearRect(0, 0, width, height);
  context.rect(0, 0, width, height);
  context.fillStyle = "#fff";
  context.fill();

  // draw links
  context.beginPath();
  data.links.forEach(function(d) { drawLink(d, transform); });
  context.strokeStyle = link_color;
  context.stroke();

  // draw arrows
  if(draw_arrows){
      data.links.forEach(function(d) {
        drawArrowHead(arrowHeadPoints(d, transform));
      });
  }

  // draw nodes
  data.nodes.forEach(function(d, i) {
    var d_color = node_color(d.group);
    context.beginPath();
    drawNode(d, transform);
    context.fillStyle = d_color;
    context.fill();
    context.strokeStyle = d_color;
    context.stroke();
  });

  // draw node labels
  data.nodes.forEach(function(d, i) {
    var d_color = node_color(d.group);
    var dx, dy, d_node_size;

    if (transform != null) {
      dx = transform.applyX(d.x);
      dy = transform.applyY(d.y);
      d_node_size = Math.pow(transform.k, zoom_scale) * node_size;
    } else {
      dx = d.x;
      dy = d.y;
      d_node_size = node_size;
    }

    var fontfillsize = 24;

    context.font = fontfillsize + "px Arial";
    context.fillStyle = d_color;
    context.strokeStyle = "white";
    context.strokeText(d.id, dx, dy);
    context.shadowColor = "rgba(0,0,0,0.9)";
    context.shadowOffsetX = 2;
    context.shadowOffsetY = 2;
    context.shadowBlur = 6;
    context.fillText(d.id, dx, dy);
    context.shadowColor = "transparent";
  });
}

function dragsubject() {
  return simulation.find(d3.event.x, d3.event.y);
}

function dragstarted() {
  if (!d3.event.active) simulation.alphaTarget(0.3).restart();
  d3.event.subject.fx = d3.event.subject.x;
  d3.event.subject.fy = d3.event.subject.y;
}

function dragged() {
  d3.event.subject.fx = d3.event.x;
  d3.event.subject.fy = d3.event.y;
}

function dragended() {
  if (!d3.event.active) simulation.alphaTarget(0);
  d3.event.subject.fx = null;
  d3.event.subject.fy = null;
}

function drawLink(d, transform) {
  var sx, sy, tx, ty;

  if (transform != null) {
    sx = transform.applyX(d.source.x);
    sy = transform.applyY(d.source.y);
    tx = transform.applyX(d.target.x);
    ty = transform.applyY(d.target.y);
  } else {
    sx = d.source.x;
    sy = d.source.y;
    tx = d.target.x;
    ty = d.target.y;
  }

  context.moveTo(sx, sy);
  context.lineTo(tx, ty);
}

function drawNode(d, transform) {
  var dx, dy, d_node_size;

  if (transform != null) {
    dx = transform.applyX(d.x);
    dy = transform.applyY(d.y);
    d_node_size = Math.pow(transform.k, zoom_scale) * node_size;
  } else {
    dx = d.x;
    dy = d.y;
    d_node_size = node_size;
  }

  context.moveTo(dx + d_node_size, dy);
  context.arc(dx, dy, d_node_size, 0, 2 * Math.PI);
}

function arrowHeadPoints(d, transform) {
  var sx, sy, tx, ty, d_node_size;

  if (transform != null) {
    sx = transform.applyX(d.source.x);
    sy = transform.applyY(d.source.y);
    tx = transform.applyX(d.target.x);
    ty = transform.applyY(d.target.y);
    d_node_size = Math.pow(transform.k, zoom_scale) * node_size;
  } else {
    sx = d.source.x;
    sy = d.source.y;
    tx = d.target.x;
    ty = d.target.y;
    d_node_size = node_size;
  }

  var t = Math.atan2(ty - sy, tx - sx);
  var dt = Math.PI * 36 / 40;

  var x1 = tx - d_node_size * Math.cos(t);
  var y1 = ty - d_node_size * Math.sin(t);

  var x2 = arrow_length * Math.cos(t + dt) + x1;
  var y2 = arrow_length * Math.sin(t + dt) + y1;

  var x3 = arrow_length * Math.cos(t - dt) + x1;
  var y3 = arrow_length * Math.sin(t - dt) + y1;

  return([{x: x1, y: y1}, {x: x2, y: y2}, {x: x3, y: y3}]);
}

function drawArrowHead(d) {
  if (solid_arrows) {
    context.beginPath();
  	context.moveTo(d[0].x, d[0].y);
  	context.lineTo(d[1].x, d[1].y);
  	context.lineTo(d[2].x, d[2].y);
    context.closePath();
    context.fillStyle = link_color;
    context.fill();

  } else {
    context.beginPath();
  	context.moveTo(d[0].x, d[0].y);
  	context.lineTo(d[1].x, d[1].y);
    context.strokeStyle = link_color;
    context.stroke();

  	context.beginPath();
  	context.moveTo(d[0].x, d[0].y);
  	context.lineTo(d[2].x, d[2].y);
    context.strokeStyle = link_color;
    context.stroke();
  }
}