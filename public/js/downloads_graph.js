var VerboseStats = VerboseStats || {
  initialize: function() {
    VerboseStats.renderDownloadGraphs();
  },

  renderDownloadGraphs: function() {
    var episodeGraphs = document.querySelectorAll('.downloads-graph');
    for (var inx=0; inx < episodeGraphs.length; inx++) {
      VerboseStats.renderDownloadGraphForEpisode(inx + 1);
    }
  },

  renderDownloadGraphForEpisode: function(episode_number) {
    var selector = '#episode-' + episode_number; 
    var palette = new Rickshaw.Color.Palette({ scheme: 'spectrum2001' });

    $.getJSON('/data/' + episode_number, function(graphdata) {
      var downloadsGraph = new Rickshaw.Graph( {
        element: document.querySelector(selector + '-graph'),
        width: 850,
        renderer: 'bar',
        series: [
          { 
            name: 'downloads',
            color: palette.color(),
            data: graphdata
          }
        ]
      } );

      var time = new Rickshaw.Fixtures.Time();
      var days = time.unit('day');

      var x_axis = new Rickshaw.Graph.Axis.Time({
        graph: downloadsGraph,
        orientation: 'bottom',
        timeUnit: days,
        element: document.querySelector(selector + '-x-axis')
      });

      var y_axis = new Rickshaw.Graph.Axis.Y( {
        graph: downloadsGraph,
        orientation: 'left',
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
        element: document.querySelector(selector + '-y-axis'),
      } );

      var hoverDetail = new Rickshaw.Graph.HoverDetail({ 
        graph: downloadsGraph,
        formatter: function(series, x, y) {
          return parseInt(y) + " downloads";
        }
      } );

      downloadsGraph.render();
    } );
  }
}