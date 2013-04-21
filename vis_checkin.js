d3.csv("vis_venues.csv", function(rows) {
    var sxsw_venues = [];
    rows.forEach(function(row) {
        sxsw_venues.push([row.venueID, row.name]);
    });

    var context = cubism.context()
        .step(3600 * 1000)
        .size(1080)
        .stop();

    d3.select("body").selectAll(".axis")
        //.data(["top", "bottom"])
        .data(["bottom"])
        .enter().append("div")
        .attr("class", function(d) { return d + " axis"; })
        .each(function(d) { d3.select(this).call(context.axis().ticks(5).orient(d)); });

    d3.select("body").append("div")
        .attr("class", "rule")
        .call(context.rule());

    d3.select("body").selectAll(".horizon")
        .data(sxsw_venues.map(checkinn_at))
        .enter().insert("div", ".bottom")
        .attr("class", "horizon")
        .call(context.horizon()
              .extent([0,50])
              .height(40)
              .format(d3.format("d")));

    context.on("focus", function(i) {
        d3.selectAll(".value").style("right", i == null ? null : context.size() - i + "px");
    });

    function checkinn_at(venue) {
        return context.metric(function(start, stop, step, callback) {
            d3.csv("data/" + venue[0] + ".csv", function(rows) {
                var values = [];
                rows.forEach(function(row) {
                    values.push(row.numb);
                });
                callback(null, values);
            });
        }, venue[1]);
    }
})
