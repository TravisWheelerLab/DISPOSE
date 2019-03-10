var baseChoice = 0;
var maxScore = 0;

function toggleChoice() {
    baseChoice ^= 1;

    update(root1, hRoot1, hRoot2, svg, svg2, root1, root2, nScore);
    update(root2, hRoot2, hRoot1, svg2, svg, root2, root1, nScore);
}

function readFiles(callback) {

    var file1 = $('#treeFile1');
    var file2 = $('#treeFile2');
    var scoresFile = $('#scoresFile');

    var reader = new FileReader();
    var reader2 = new FileReader();
    var reader3 = new FileReader();

    reader.onload = function() {
        reader2.onload = function() {
            reader3.onload = function() {
                callback(reader.result, reader2.result, reader3.result);
            };
        };
    };

    reader.readAsText(file1[0].files[0]);
    reader2.readAsText(file2[0].files[0]);
    reader3.readAsText(scoresFile[0].files[0]);
}

function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}

function swapJsonKeyValues(input) {
    var output = {};
    for (const [k1, v1] of Object.entries(input)) {
        for (const [k2, v2] of Object.entries(v1)) {
            if (output[k2] == null) {
                output[k2] = {};
            }
            output[k2][k1] = v2;
        }
    }
    return output;
}

function findMax(nScore) {
    for (const [k1, v1] of Object.entries(nScore)) {
        for (const [k2, v2] of Object.entries(v1)) {
            if (v2 > maxScore)
                maxScore = v2;
        }
    }
}

function drawLink(d, b) {
    return "M" + d.x + "," + d.y +
        "C" + d.x + "," + (d.y + b.y) / 2 +
        " " + b.x + "," + (d.y + b.y) / 2 +
        " " + b.x + "," + b.y;
}

var treeData;
var treeData2;
var nScore;
var nScore2;

var margin;
var tree;

var svg;
var svg2;

var svgContainer1;
var svgContainer2;

var hRoot1;
var hRoot2;

var i = 0,
    duration = 750,
    root, root2;

function treeCompare(treeData, treeData2, t_nScore) {

    treeData = JSON.parse(treeData);
    treeData2 = JSON.parse(treeData2);
    nScore = JSON.parse(t_nScore);
    nScore2 = swapJsonKeyValues(nScore);

    findMax(nScore);

    console.log(nScore);
    console.log(nScore2);

    $('#tree1').html('');
    $('#tree2').html('');

    $('#nodeName1').html('');
    $('#weight1').html('');
    $('#pos1').html('');
    $('#nodeTotal1').html('');
    $('#nodeScore1').html('');

    $('#nodeName2').html('');
    $('#weight2').html('');
    $('#pos2').html('');
    $('#nodeTotal2').html('');
    $('#nodeScore2').html('');

    // ************** Generate the tree diagram  *****************

    margin = {
            top: 40,
            right: 20,
            bottom: 20,
            left: 20
        },
        width = window.innerWidth*3.0 - margin.right - margin.left,
        height = window.innerHeight / 1.2 - margin.top - margin.bottom;

    tree = d3.tree()
        .size([width, height]);

    svg = d3.select("#tree1")
        .attr("id", "tree1")
        .attr("width", width + margin.right + margin.left)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    svgContainer1 = d3.select("#treeContainer1")
        .call(d3.zoom()
            .filter(() => {
                if (d3.event.type === 'wheel') {
                    return d3.event.ctrlKey;
                }
                if (d3.event.type === 'mousedown') {
                    return d3.event.altKey;
                }

                return true;
            })
            .on("zoom", function() {
                svg.attr("transform", d3.event.transform);
            }));

    svg2 = d3.select("#tree2")
        .attr("id", "tree2")
        .attr("width", width + margin.right + margin.left)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    svgContainer2 = d3.select("#treeContainer2")
        .call(d3.zoom()
            .filter(() => {
                if (d3.event.type === 'wheel') {
                    return d3.event.ctrlKey;
                }
                if (d3.event.type === 'mousedown') {
                    return d3.event.altKey;
                }

                return true;
            })
            .on("zoom", function() {
                svg2.attr("transform", d3.event.transform);
            }));

    root1 = treeData[0];
    hRoot1 = d3.hierarchy(root1);
    root1.x0 = width / 2;
    root1.y0 = 0;

    root2 = treeData2[0];
    hRoot2 = d3.hierarchy(root2);
    root2.x0 = width / 2;
    root2.y0 = 0;


    update(root1, hRoot1, hRoot2, svg, svg2, root1, root2, nScore);
    update(root2, hRoot2, hRoot1, svg2, svg, root2, root1, nScore);
}

function updateScore(nScore) {
    var firstHash = d3.select("#nodeName1").attr("meta");
    console.log("FIRST: " + firstHash);
    var secondHash = d3.select("#nodeName2").attr("meta");
    console.log("SECOND: " + secondHash);

    if (firstHash != null)
        var score = nScore[firstHash][secondHash];
    console.log(score);
    d3.select("#nodeScore1").text(score);
    d3.select("#nodeScore2").text(score);
}

function getDescendants(node, children) {
    children.push(node);

    if (node.children != null)
        node.children.forEach(function(d) {
            getDescendants(d, children);
        })
    return children;
}

function containsObject(obj, list) {
    var i;
    for (i = 0; i < list.length; i++) {
        if (list[i] === obj) {
            return true;
        }
    }

    return false;
}

function findPath(node, list, tree) {

    if (tree == 1) {
        var nScores = nScore[node.data.nid];
        var maxId = 0;
        var maxVal = 0;
        if (nScores != null) {
            for (const [key, value] of Object.entries(nScores)) {
                if (value > maxVal) {
                    maxId = node.data.nid;
                    maxVal = value;
                }
            }

            list.push([maxId, maxVal]);

            if (node.children != null) {
                node.children.forEach(function(d) {
                    findPath(d, list, tree);
                })
            }
        }
    }
    else {
        var nScores2 = nScore2[node.data.nid];
        var maxId = 0;
        var maxVal = 0;

        if (nScores2 != null) {
            for (const [key, value] of Object.entries(nScores2)) {
                if (value > maxVal) {
                    maxId = node.data.nid;
                    maxVal = value;
                }
            }

            list.push([maxId, maxVal]);

            if (node.children != null) {
                node.children.forEach(function(d) {
                    findPath(d, list, tree);
                })
            }
        }
    }
}

var curFirst = null;
var curSec = null;

var curFirstVal = null;
var curSecVal = null;

var curFirstChildren = [];
var curSecChildren = [];

var pathList = [];
var pathList2 = [];

function update(source, hRootA, hRootB, source_svg, other_svg, rootA, rootB, nScore) {
    // Compute the new tree layout.
    var newTreeData = tree(hRootA);

    var nodes = newTreeData.descendants(),
        links = newTreeData.descendants().slice(1);

    // Normalize for fixed-depth.
    nodes.forEach(function(d) {
        d.y = d.depth * 50;
    });

    // Update the nodes…
    var node = source_svg.selectAll("g.node")
        .data(nodes, function(d) {
            return d.id || (d.id = ++i);
        });

    // Enter any new nodes at the parent's previous position.
    var nodeEnter = node.enter().append("g")
        .attr("class", "node")
        .attr("transform", function(d) {
            return "translate(" + source.x0 + "," + source.y0 + ")";
        })
        // right-click collapse tree
        .on("contextmenu", function(d) {
            d3.event.preventDefault();
            if (d.children) {
                d._children = d.children;
                d.children = null;
            } else {
                d.children = d._children;
                d._children = null;
            }
            update(d, hRootA, hRootB, source_svg, other_svg, rootA, rootB, nScore);
        })
        // left-click find matches and total scores
        .on("click", function(d) {
            // First tree
            if (Object.is(source_svg, svg)) {
                var nameLabel1 = `
                <div id='shortHash1' class="hasTooltip">` + escapeHtml(d.data.name) +
                    `<span id='longHash1' style='max-width:100%'>` + escapeHtml(d.data.hashVal) + `</span>
                </div>`

                // Update node information
                d3.select("#nodeName1").html(nameLabel1)
                    .attr("meta", d.data.nid);
                d3.select("#weight1").text(d.data.weight);
                d3.select("#pos1").text((d.data.start) + ":" + (d.data.end));

                curFirst = d;
                curFirstVal = curFirst.data.nid;

                curFirstChildren = [];
                curFirstChildren = getDescendants(curFirst, curFirstChildren);

                pathList = [];
                findPath(curFirst, pathList, 1);

                // Update node total
                var nScores = nScore[curFirstVal];
                var nTotal = 0;
                for (const [key, value] of Object.entries(nScores)) {
                    if (value > nTotal)
                        nTotal = value;
                }
                d3.select("#nodeTotal1").text(nTotal);

                // Update highlights
                var start = d.data.start;
                var end = d.data.end;
                var select = '';

                $("#code1 .line").removeClass("highlighted");

                for (var i = start; i <= end; i++) {
                    select = "#line1_" + i;
                    $(select).addClass("highlighted");
                }
            // Second tree
            } else {
                var nameLabel2 = `
                <div id='shortHash2' class="hasTooltip">` + escapeHtml(d.data.name) +
                    `<span id='longHash2' style='max-width:100%''>` + escapeHtml(d.data.hashVal) + `</span>
                </div>`
                d3.select("#nodeName2").html(nameLabel2)
                    .attr("meta", d.data.nid);
                d3.select("#weight2").text(d.data.weight);
                d3.select("#pos2").text((d.data.start) + ":" + (d.data.end));

                curSec = d;
                curSecVal = curSec.data.nid;

                curSecChildren = [];
                curSecChildren = getDescendants(curSec, curSecChildren);

                pathList2 = [];
                findPath(curSec, pathList2, 2);

                // Update node total
                var nTotal = 0;
                for (const [key, value] of Object.entries(nScore)) {
                    if (value[curSecVal] != null) {
                        if (value[curSecVal] > nTotal)
                        nTotal = value[curSecVal];
                    }
                }
                d3.select("#nodeTotal2").text(nTotal);

                // Update highlights
                var start = d.data.start;
                var end = d.data.end;
                var select = '';

                $("#code2 .line").removeClass("highlighted");

                for (var i = start; i <= end; i++) {
                    select = "#line2_" + i;
                    $(select).addClass("highlighted");
                }
            }

            update(d, hRootA, hRootB, source_svg, other_svg, rootA, rootB, nScore);
            update(d, hRootB, hRootA, other_svg, source_svg, rootB, rootA, nScore);

            updateScore(nScore);
        })
        .on("mouseover", function(d) {
            if (curFirstVal != null && curSecVal != null) {
                if (pathList.length != 0) {
                    if (Object.is(source_svg, svg)) {
                        for (var i = 0; i < pathList.length; i++) {
                            if (d.data.nid == pathList[i][0]) {
                                d3.select(this).select('text').text(function(d) {
                                    return Math.round(pathList[i][1] * 100) / 100;
                                });
                            }
                        }
                    } else {
                        for (var i = 0; i < pathList2.length; i++) {
                            if (d.data.nid == pathList2[i][0]) {
                                d3.select(this).select('text').text(function(d) {
                                    return Math.round(pathList2[i][1] * 100) / 100;
                                });
                            }
                        }
                    }
                }
            }
        })
        .on("mouseout", function(d) {
            d3.select(this).select('text').text(function(d) {
                if (d.data.name.length >= 10) {
                    return d.data.name.substring(0, 9);
                } else {
                    return d.data.name;
                }
            });
        });

    nodeEnter.append("circle")
        .attr('class', 'node')
        .attr("r", 1e-6)
        .style("fill", function(d) {
            return d._children ? "lightsteelblue" : "#fff";
        });

    nodeEnter.append("text")
        .attr("y", function(d) {
            return d.children || d._children ? -18 : 18;
        })
        .attr("dy", ".35em")
        .attr("text-anchor", "middle")
        .text(function(d) {
            if (d.data.name.length >= 10) {
                return d.data.name.substring(0, 9);
            } else {
                return d.data.name;
            }
        })
        .style("fill-opacity", 1e-6);

    var nodeUpdate = nodeEnter.merge(node);

    // Transition nodes to their new position.
    nodeUpdate.transition()
        .duration(duration)
        .attr("transform", function(d) {
            return "translate(" + d.x + "," + d.y + ")";
        });

    nodeUpdate.select("circle.node")
        .attr("r", 10)
        .attr('cursor', 'pointer')
        .style("fill", function(d) {
            if (Object.is(source_svg, svg2)) {

                if (curSec == d) {
                    return "LimeGreen";
                }

                if (curFirstVal != null) {
                    if (nScore[curFirstVal][d.data.nid] > 0.0) {
                        return "cyan";
                    }
                }
            } else {

                if (curFirst == d) {
                    return "LimeGreen";
                }

                if (curSecVal != null) {
                    if (nScore[d.data.nid] != null) {
                        if (nScore[d.data.nid][curSecVal] > 0.0) {
                            return "cyan";
                        }
                    }
                }
            }

            // Plasma colourmap
            var colorGrad = ["#0600E5", "#5402E6", "#A005E8", "#EA07E8", "#EC0AA0", "#ED0D59", "#EF1012", "#F15913", "#F3A316", "#F5ED19"];
            if (baseChoice) {
                if (curFirstVal != null && curSecVal != null) {
                    if (pathList.length != 0) {
                        if (Object.is(source_svg, svg)) {
                            for (var i = 0; i < pathList.length; i++) {
                                if (d.data.nid == pathList[i][0]) {
                                    return colorGrad[Math.trunc(pathList[i][1] / nScore[curFirstVal][curSecVal] * 10)];
                                }
                            }
                        } else {
                            for (var i = 0; i < pathList2.length; i++) {
                                if (d.data.nid == pathList2[i][0]) {
                                    return colorGrad[Math.trunc(pathList2[i][1] / nScore[curFirstVal][curSecVal] * 10)];
                                }
                            }
                        }
                    }
                }
            }
            else {
                if (Object.is(source_svg, svg)) {
                    var nScores = nScore[d.data.nid];
                    var nTotal = 0;
                    if (nScores != null) {
                        for (const [key, value] of Object.entries(nScores)) {
                            if (value > nTotal)
                                nTotal = value;
                        }
                    }
                    if (nTotal == maxScore)
                        return "LimeGreen";

                    if (nTotal != 0)
                        return colorGrad[Math.trunc(nTotal / maxScore * 10)];
                }
                else {
                    var nScores = nScore2[d.data.nid];
                    var nTotal = 0;
                    if (nScores != null) {
                        for (const [key, value] of Object.entries(nScores)) {
                            if (value > nTotal)
                                nTotal = value;
                        }
                    }

                    if (nTotal == maxScore)
                        return "LimeGreen";

                    if (nTotal != 0)
                        return colorGrad[Math.trunc(nTotal / maxScore * 10)];
                }
            }

            return d._children ? "lightsteelblue" : "#fff";
        });

    nodeUpdate.select("text")
        .style("fill-opacity", 1);

    // Transition exiting nodes to the parent's new position.
    var nodeExit = node.exit().transition()
        .duration(duration)
        .attr("transform", function(d) {
            return "translate(" + source.x + "," + source.y + ")";
        })
        .remove();

    nodeExit.select("circle")
        .attr("r", 1e-6);

    nodeExit.select("text")
        .style("fill-opacity", 1e-6);

    // Update the links...
    var link = source_svg.selectAll('path.link')
        .data(links, function(d) {
            return d.id;
        });

    // Enter any new links at the parent's previous position.
    var linkEnter = link.enter().insert('path', "g")
        .attr("class", "link")
        .attr('d', function(d) {
            var o = {
                x: source.x0,
                y: source.y0
            }
            return drawLink(o, o);
        });

    // // UPDATE
    var linkUpdate = linkEnter.merge(link);

    // Transition back to the parent element position
    linkUpdate.transition()
        .duration(duration)
        .attr('d', function(d) {
            return drawLink(d, d.parent);
        });

    // Remove any exiting links
    var linkExit = link.exit().transition()
        .duration(duration)
        .attr('d', function(d) {
            var o = {
                x: source.x,
                y: source.y
            }
            return drawLink(o, o);
        })
        .remove();

    // Stash the old positions for transition.
    nodes.forEach(function(d) {
        d.x0 = d.x;
        d.y0 = d.y;
    });
}

// Window drag from here: https://www.w3schools.com/howto/howto_js_draggable.asp

function dragElement(elmnt) {
    var pos1 = 0,
        pos2 = 0,
        pos3 = 0,
        pos4 = 0;
    if (document.getElementById(elmnt.id + "Head")) {
        // if present, the header is where you move the DIV from:
        document.getElementById(elmnt.id + "Head").onmousedown = dragMouseDown;
    } else {
        // otherwise, move the DIV from anywhere inside the DIV: 
        elmnt.onmousedown = dragMouseDown;
    }

    function dragMouseDown(e) {
        e = e || window.event;
        e.preventDefault();
        // get the mouse cursor position at startup:
        pos3 = e.clientX;
        pos4 = e.clientY;
        document.onmouseup = closeDragElement;
        // call a function whenever the cursor moves:
        document.onmousemove = elementDrag;
    }

    function elementDrag(e) {
        e = e || window.event;
        e.preventDefault();
        // calculate the new cursor position:
        pos1 = pos3 - e.clientX;
        pos2 = pos4 - e.clientY;
        pos3 = e.clientX;
        pos4 = e.clientY;
        // set the element's new position:
        elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
        elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
    }

    function closeDragElement() {
        // stop moving when mouse button is released:
        document.onmouseup = null;
        document.onmousemove = null;
    }
}

// Pinning functionality
$(document).ready(function() {

    var pinned1 = false;
    var pinned2 = false;

    $("#pin1").click(function() {
        if (!pinned1) {
            var offset = $("#treeInfo1").position();
            $("#treeInfo1").css({
                position: "absolute",
                top: offset.top + $(document).scrollTop()
            });
            $("#pin1").css("background-color", "#ff0000");
            pinned1 = true;

        } else {
            var offset = $("#treeInfo1").position();
            $("#treeInfo1").css({
                position: "fixed",
                top: offset.top - $(document).scrollTop()
            });
            $("#pin1").css("background-color", "#42f448");
            pinned1 = false;
        }
    });

    $("#pin2").click(function() {
        if (!pinned2) {
            var offset = $("#treeInfo2").position();
            $("#treeInfo2").css({
                position: "absolute",
                top: offset.top + $(document).scrollTop()
            });
            $("#pin2").css("background-color", "#ff0000");
            pinned2 = true;

        } else {
            var offset = $("#treeInfo2").position();
            $("#treeInfo2").css({
                position: "fixed",
                top: offset.top - $(document).scrollTop()
            });

            $("#pin2").css("background-color", "#42f448");
            pinned2 = false;
        }
    });
});