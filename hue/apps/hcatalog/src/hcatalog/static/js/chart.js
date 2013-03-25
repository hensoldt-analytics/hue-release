document.write('<link rel="stylesheet" type="text/css" href="/hcatalog/static/css/detail.css">');
document.write('<link rel="stylesheet" type="text/css" href="/hcatalog/static/css/graph.css">');
document.write('<link rel="stylesheet" type="text/css" href="/hcatalog/static/css/legend.css">');
document.write('<link rel="stylesheet" type="text/css" href="/hcatalog/static/css/chart.css">');
document.write('<link rel="stylesheet" type="text/css" href="/hcatalog/static/css/jquery-ui.css">');
document.write('<script src="/static/ext/js/jquery/jquery-1.8.1.min.js"></script> ');
document.write('<script src="/hcatalog/static/js/jquery-ui.min.js"></script> ');
document.write('<script src="/hcatalog/static/js/d3.v3.min.js"></script>');
document.write('<script src="/hcatalog/static/js/lib/d3.layout.min.js"></script>');
document.write('<script src="/hcatalog/static/js/lib/rickshaw.min.js"></script>');
function chart(x,y)
{
	this.x = x;
	this.y = y;
	this.n = y.length;
	var map = {};
	this.seriesData = [[]];
	this.palette = new Rickshaw.Color.Palette( { scheme: 'colorwheel' } );

	this.getData = function(d,i)
	{
		for(var k=0;k<this.n;k++)
		{
			this.seriesData.push([]);
			this.seriesData[k].push({x: i, y: parseInt(d[this.y[k]])});
		}
		map[i] = d[this.x];
	}

	this.setGraph = function(type,unstack)
	{


		this.graph = new Rickshaw.Graph({
			element: document.getElementById("chart"),
			width: 900,
			height: 400,
			renderer: type,
			unstack: unstack,
			series:
			[{
				color: this.palette.color(),
				data: this.seriesData[0],
				name: this.y[0]
			}]
		});

		for(var k=1;k<this.n;k++)
		this.graph.series.push({color: this.palette.color() , data: this.seriesData[k], name: this.y[k]});

		this.legend = new Rickshaw.Graph.Legend({
			graph: this.graph,
			element: document.querySelector('#legend')
		});

		this.hoverDetail = new Rickshaw.Graph.HoverDetail( {
			graph: this.graph
		});

		this.yAxis = new Rickshaw.Graph.Axis.Y({
			graph: this.graph,
			orientation: 'left',
			element: document.getElementById('y_axis')
		});
		var format = function(n)
		{
			return map[n];
		}
		this.xAxis = new Rickshaw.Graph.Axis.X( {
			graph: this.graph,
			orientation: 'bottom',
			element: document.getElementById('x_axis'),
			tickFormat:format

		});

		this.graph.render();

		this.slider = new Rickshaw.Graph.RangeSlider({
			graph: this.graph,
			element: document.getElementById('slider')
		});
	}
}
