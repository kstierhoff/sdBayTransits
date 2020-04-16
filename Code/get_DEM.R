# Get bounding box around nav
sd.bbox <- nav %>%
  st_as_sf(coords = c("long","lat"), crs = 4326) %>%
  st_bbox()

nav.dem <- nav %>%
  dplyr::select(x = long, y = lat)

proj.str <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

clip.coords = ggmap::geocode("San Diego, CA")

# Use elevatr::get_elev_raster
elevatr.raster <- get_elev_raster(nav.dem, prj = proj.str, z = 11)

# Use geoviz to crop the raster to San Diego
# elevatr.raster <- elevatr.raster %>%
#   geoviz::crop_raster_square(clip.coords$lat, clip.coords$lon, square_km = 10)

# elevatr.raster <- elevatr.raster %>%
#   geoviz::crop_raster_square(mean(nav$lat), mean(nav$long), square_km = 12)

elevatr.raster <- crop_raster_track(elevatr.raster, nav$lat, nav$long, width_buffer = 2)

plot(elevatr.raster)

elevatr.mat <- raster_to_matrix(elevatr.raster)

elevatr.mat %>%
  sphere_shade(texture = "imhof4") %>%
  plot_map()

# elevatr.mat %>%
#   sphere_shade(texture = "imhof4") %>%
#   add_shadow(ray_shade(elevatr.mat, zscale = 30), 0.5) %>%
#   add_shadow(ambient_shade(elevatr.mat), 0) %>%
#   plot_3d(elevatr.mat, zscale = 30, fov = 0, theta = -10, phi = 30,
#           windowsize = c(1000, 800), zoom = 0.75,
#           water = FALSE, waterdepth = 0, wateralpha = 0.40, watercolor = "lightblue",
#           waterlinecolor = "white", waterlinealpha = 0.5)

overlay_image <-
  slippy_overlay(elevatr.raster, image_source = "mapbox", image_type = "satellite", png_opacity = 0.5,
                 api_key = MAPBOX_API_KEY)

# overlay_image <-
#   slippy_overlay(elevatr.raster, image_source = "stamen", image_type = "mapbox-terrain-v2", png_opacity = 0.5,
#                  api_key = MAPBOX_API_KEY)

# #Optionally, turn mountainous parts of the overlay transparent
# overlay_image <-
#   elevation_transparency(overlay_image,
#                          elevatr.mat,
#                          pct_alt_high = 0.5,
#                          alpha_max = 0.9)


nav.sub <- nav %>%
  filter(cruise == 30) %>%
  mutate(alt = 1.5)

scene <- elevatr.mat %>%
  sphere_shade(sunangle = 270, texture = "desert") %>%
  add_overlay(overlay_image)

rgl::rgl.clear()

rayshader::plot_3d(
  scene,
  elevatr.mat,
  zscale = 5,
  fov = 0, theta = -10, phi = 30,
  windowsize = c(1000, 800), zoom = 0.3,
  water = TRUE, waterdepth = 1, wateralpha = 0.20, watercolor = "lightblue",
  waterlinecolor = "white", waterlinealpha = 0.5, solid = FALSE)

add_gps_to_rayshader(
  elevatr.raster,
  nav.sub$lat,
  nav.sub$long,
  nav.sub$alt,
  line_width = 1.5,
  lightsaber = TRUE,
  colour = "red",
  zscale = 20,
  ground_shadow = TRUE
)

