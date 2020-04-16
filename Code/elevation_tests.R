url <- 'https://raw.githubusercontent.com/plotly/datasets/master/2011_february_aa_flight_paths.csv'
flights <- read.csv(url)
flights$id <- seq_len(nrow(flights))
flights$stroke <- sample(1:3, size = nrow(flights), replace = T)

library(mapdeck)

mapdeck(token = MAPBOX_API_KEY, style = mapdeck_style("dark"), pitch = 45) %>%
  add_arc(
    data = flights
    , layer_id = "arc_layer"
    , origin = c("start_lon", "start_lat")
    , destination = c("end_lon", "end_lat")
    , stroke_from = "airport1"
    , stroke_to = "airport2"
    , stroke_width = "stroke"
  )

url <- 'https://raw.githubusercontent.com/plotly/datasets/master/2011_february_aa_flight_paths.csv'
flights <- read.csv(url)
flights$id <- seq_len(nrow(flights))
flights$stroke <- sample(1:3, size = nrow(flights), replace = T)

mapdeck(token = "pk.eyJ1Ijoia3N0aWVyaG9mZiIsImEiOiJjam96ejNuZnAwMXN3M2tudWtwNHdzZTMzIn0.TzQS2hEWzxm16ww-uPFO7w",
        style = 'mapbox://styles/mapbox/dark-v9') %>%
  add_greatcircle(
    data = flights
    , layer_id = "arc_layer"
    , origin = c("start_lon", "start_lat")
    , destination = c("end_lon", "end_lat")
    , stroke_from = "airport1"
    , stroke_to = "airport2"
    , stroke_width = "stroke"
  )

library(sf)

uluru_bbox <-
  st_bbox(c(xmin = 131.02084,
            xmax = 131.0535,
            ymin = -25.35461,
            ymax = -25.33568),
          crs = st_crs("+proj=longlat +ellps=WGS84"))

bbox_tile_query(uluru_bbox)

mapbox_query_string <-
  paste0("https://api.mapbox.com/v4/mapbox.satellite/{zoom}/{x}/{y}.jpg90",
         "?access_token=",
         "pk.eyJ1Ijoia3N0aWVyaG9mZiIsImEiOiJjam96ejNuZnAwMXN3M2tudWtwNHdzZTMzIn0.TzQS2hEWzxm16ww-uPFO7w")

library(purrr)
library(curl)
library(glue)

tile_grid <- bbox_to_tile_grid(uluru_bbox, max_tiles = 15)

images <-
  pmap(tile_grid$tiles,
       function(x, y, zoom){
         outfile <- glue("{x}_{y}.jpg")
         curl_download(url = glue(mapbox_query_string),
                       destfile = outfile)
         outfile
       },
       zoom = tile_grid$zoom)

library(raster)
library(rgdal)

raster_out <- compose_tile_grid(tile_grid, images)

## A convenient wrapper for raster image exports using png::writePNG.
raster_to_png(raster_out, "uluru.png")

library(rayshader)

uluru.mat <- raster_out %>%
  raster_to_matrix()

uluru.mat %>%
  sphere_shade(texture = "desert") %>%
  add_water(detect_water(uluru.mat), color = "desert") %>%
  plot_map()

uluru.mat %>%
  sphere_shade(texture = "desert") %>%
  add_water(detect_water(uluru.mat), color = "desert") %>%
  add_shadow(ray_shade(uluru.mat, zscale = 13), 0.5) %>%
  add_shadow(ambient_shade(uluru.mat), 0) %>%
  plot_3d(uluru.mat, zscale = 1, fov = 0, theta = -10, zoom = 0.75, phi = 30, windowsize = c(1000, 800))

rgl::rgl.clear()

library(marmap)

sd.marmap <- getNOAA.bathy(lon1 = -119, lon2 = -117,
                        lat1 = 30, lat2 = 33, resolution = 1)

sd.mat <- as.matrix(sd.marmap)

sd.mat %>%
  sphere_shade(texture = "desert") %>%
  add_water(detect_water(sd.mat), color = "desert") %>%
  plot_map()


rgl::rgl.clear()

sd.mat %>% sphere_shade(texture = "desert") %>%
  # add_water(detect_water(sd.mat), color = "desert") %>%
  add_shadow(ray_shade(sd.mat, zscale = 50), 0.5) %>%
  add_shadow(ambient_shade(sd.mat), 0) %>%
  plot_3d(sd.mat, waterdepth = 0, zscale = 50, fov = 0, theta = -10, zoom = 0.75, phi = 30, windowsize = c(1000, 800))


scb <- raster::raster(here::here("Data/rayshader_tiffs", "scb.tif")) %>%
  raster_to_matrix()

rgl::rgl.clear()

scb %>% sphere_shade(texture = "imhof1") %>%
  add_shadow(ray_shade(scb, zscale = 50), 0.5) %>%
  add_shadow(ambient_shade(scb), 0) %>%
  plot_3d(scb, zscale = 50, fov = 0, theta = -10, zoom = 0.75, phi = 30, windowsize = c(1000, 800),
          water = TRUE, waterdepth = 0, wateralpha = 0.5, watercolor = "lightblue",
          waterlinecolor = "white", waterlinealpha = 0.5)

if (render.hi){
  render_highquality(filename = here::here("Figs/scb_rayrender.png"),
                     lightdirection = 0, lightaltitude  = 30, clamp_value = 10,
                     samples=200)
} else {
  render_snapshot(filename = here::here("Figs/scb_rayrender.png"))
}
