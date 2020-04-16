url <- 'https://raw.githubusercontent.com/plotly/datasets/master/2011_february_aa_flight_paths.csv'
flights <- read.csv(url)
flights$id <- seq_len(nrow(flights))
flights$stroke <- sample(1:3, size = nrow(flights), replace = T)

mapdeck::mapdeck(token = MAPBOX_API_KEY, style = mapdeck_style("dark"), pitch = 45) %>%
  add_arc(
    data = flights
    , layer_id = "arc_layer"
    , origin = c("start_lon", "start_lat")
    , destination = c("end_lon", "end_lat")
    , stroke_from = "airport1"
    , stroke_to = "airport2"
    , stroke_width = "stroke"
  )

mapdeck(
  token = MAPBOX_API_KEY
  , pitch = 35
) %>%
  add_geojson(
    data = geojson
    , layer_id = "geojson"
  )
