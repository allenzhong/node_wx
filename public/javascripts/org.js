var Log = {
    elem: false,
    write: function(text) {
        if (!this.elem)
            this.elem = document.getElementById('log');
        this.elem.innerHTML = text;
        this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
    }
};

function init() {

    //Create node line
    $jit.ST.Plot.NodeTypes.implement({
        'nodeline': {
            'render': function(node, canvas, animating) {
                if (animating === 'expand' || animating === 'contract') {
                    var pos = node.pos.getc(true),
                        nconfig = this.node,
                        data = node.data;
                    var width = nconfig.width,
                        height = nconfig.height;
                    var algnPos = this.getAlignedPos(pos, width, height);
                    var ctx = canvas.getCtx(),
                        ort = this.config.orientation;
                    ctx.beginPath();
                    if (ort == 'left' || ort == 'right') {
                        ctx.moveTo(algnPos.x, algnPos.y + height / 2);
                        ctx.lineTo(algnPos.x + width, algnPos.y + height / 2);
                    } else {
                        ctx.moveTo(algnPos.x + width / 2, algnPos.y);
                        ctx.lineTo(algnPos.x + width / 2, algnPos.y + height);
                    }
                    ctx.stroke();
                }
            }
        }

    });

    //Create a new instance
    var st = new $jit.ST({
        'injectInto': 'infovis',
        //set duration for the animation
        duration: 500,
        //set animation transition type
        transition: $jit.Trans.Quart.easeInOut,
        levelDistance: 50,
        levelsToShow: 1,
        Node: {
            height: 46,
            width: 90,
            type: 'nodeline',
            color: '#2A6DB6',
            lineWidth: 2,
            align: "center",
            overridable: false
        },

        Edge: {
            type: 'bezier',
            lineWidth: 2,
            color: '#23A4FF',
            overridable: true
        },

        //Retrieve the json data from database and create json objects for org chart
        request: function(nodeId, level, onComplete) {
            // alert("request");
            // //Generate sample data
            // if (nodeId != 'peter wang' && nodeId != 'William chen') {
            //     var data = [{
            //         fullname: 'peter wang',
            //         title: 'engineer'
            //     }, {
            //         fullname: 'William chen',
            //         title: 'senior engineer'
            //     }];
            //     var objs = [];
            //     for (var i = 0; i < data.length; i++) {
            //         var tmp = data[i];
            //         var obj = {
            //             "id": data[i].fullname,
            //             "name": "<div class='orgchartnode'>" + data[i].fullname + "</div>(" + data[i].title + ")"
            //         };
            //         objs.push(obj);
            //     }
            $.ajax({
                type: 'GET',
                url: '/admin/follower/orgmap?id=' + nodeId
            }).done(function(res) {
                var nodeobjs = {};
                nodeobjs.id = nodeId;
                nodeobjs.children = res.children;
                onComplete.onComplete(nodeId, nodeobjs);
            });
            // var nodeobjs = {};
            // nodeobjs.id = nodeId;
            // nodeobjs.children = objs;
            // onComplete.onComplete(nodeId, nodeobjs);
            // } else {
            //     var nodeobjs = {};
            //     onComplete.onComplete(nodeId, nodeobjs);
            // }

        },

        onBeforeCompute: function(node) {
            //Log.write("<div style=\"text-align:center\">Loading ...</div>");
            $("#orgchartori").fadeOut();
        },

        onAfterCompute: function() {
            //Log.write("");
            $("#orgchartori").fadeIn();
        },

        onCreateLabel: function(label, node) {
            label.id = node.id;

            label.innerHTML = "<table><tr><td><img src='" + node.data.headimgurl + "'' style='width:30px;height:30px;'/></td><td>  " +
                node.name; + "</td></tr></table>"
            label.onclick = function() {
                st.onClick(node.id);
            };
            //set label styles

            var style = label.style;
            style.width = 90 + 'px';
            style.height = 40 + 'px';
            style.cursor = 'pointer';
            style.color = '#fff';
            style.border = '3px solid #888';
            style.backgroundColor = '#2A7AC6';
            style.fontSize = '10px';
            style.fontweight = 'bold';
            style.textAlign = 'center';
            style.textDecoration = 'none';
            style.paddingTop = '1px';

        },

        onBeforePlotNode: function(node) {
            //alert('onbefore');
            if (node.selected) {
                node.data.$color = "#000";
            } else {
                delete node.data.$color;
            }
        },

        onBeforePlotLine: function(adj) {
            if (adj.nodeFrom.selected && adj.nodeTo.selected) {
                adj.data.$color = "#333333";
                adj.data.$lineWidth = 3;
            } else {
                delete adj.data.$color;
                delete adj.data.$lineWidth;
            }
        },
        onComplete: function() {
            //Log.write("done");

            //Build the right column relations list.
            //This is done by collecting the information (stored in the data property) 
            //for all the nodes adjacent to the centered node.
            var node = st.graph.getClosestNodeToOrigin("current");
            var html = "<h4>" + node.name + "</h4><b>Connection</b>";
            html += "<ul>";
            node.eachAdjacency(function(adj) {
                var child = adj.nodeTo;
                if (child.data) {
                    var rel = (child.data.band == node.name) ? child.data.relation : node.data.relation;
                    html += "<li>" + child.name + "</li>";
                }
            });
            html += "</ul > ";
            $jit.id('inner-details').innerHTML = html;
        }
    });

    $.ajax({
        type: 'GET',
        url: '/admin/follower/orgmap?id=' + openid
    }).done(function(res) {
        st.loadJSON(res);
        st.compute();
        st.onClick(st.root);
    });
    // //load json data
    // var json = " {
    // id: \"terry li\", name:\"<div class='orgchartnode'>Terry Li</div>(General Manager)\", data:{}, children:[{id:\"Jack lu\", name:\"<div class='orgchartnode'>Jack Lu</div>(QA Manager)\", data:{},children:[]},{id:\"Michelle lu\", name:\"<div class='orgchartnode'>Michelle Lu</div>(Dev Manager)\", data:{},children:[]}]}";

    // st.loadJSON(eval('(' + json + ')'));
    // //compute node positions and layout
    // st.compute();
    // //emulate a click on the root node.
    // st.onClick(st.root);
    //end

    // //Change chart direction
    // $("#top").click(function() {
    //     $("#orgchartori").fadeOut();
    //     st.switchPosition($("#top").attr("id"), "animate", {
    //         onComplete: function() {
    //             $("#orgchartori").fadeIn();
    //         }
    //     });
    // });

    // $("#bottom").click(function() {
    //     $("#orgchartori").fadeOut();
    //     st.switchPosition($("#bottom").attr("id"), "animate", {
    //         onComplete: function() {
    //             $("#orgchartori").fadeIn();
    //         }
    //     });
    // });

    // $("#right").click(function() {
    //     $("#orgchartori").fadeOut();
    //     st.switchPosition($("#left").attr("id"), "animate", {
    //         onComplete: function() {
    //             $("#orgchartori").fadeIn();
    //         }
    //     });
    // });

    // $("#left").click(function() {
    //     $("#orgchartori").fadeOut();
    //     st.switchPosition($("#right").attr("id"), "animate", {
    //         onComplete: function() {
    //             $("#orgchartori").fadeIn();
    //         }
    //     });
    // });
    //end

}