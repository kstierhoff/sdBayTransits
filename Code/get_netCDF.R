dem.name <- here::here("Data/netCDF/san_diego_13_mhw_2012.nc")

dem.df <- tidync(dem.name) %>%
  hyper_filter(lon = between(lon, -117.3, -117.15),
               lat = between(lat, 32.62, 32.8)) %>%
  hyper_tibble() %>%
  dplyr::select(lon, lat, z = Band1)

dem.ras <- raster::rasterFromXYZ(dem.df)

raster::crs(dem.ras) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

dem.ras <- raster::aggregate(dem.ras, fact = 4)

dem.mat <- raster_to_matrix(dem.ras)

# dem.mat %>%
#   sphere_shade(texture = "desert") %>%
#   plot_map()


# Subset nav
nav.sub <- nav %>%
  filter(cruise == 30) %>%
  mutate(alt = 1)

# rgl::rgl.clear()

# Plot 3D
dem.mat %>%
  sphere_shade(texture = "desert") %>%
  add_shadow(ray_shade(dem.mat, zscale = 3), 0.5) %>%
  add_shadow(ambient_shade(dem.mat), 0) %>%
  plot_3d(dem.mat, zscale = 4, fov = 0, theta = 45, phi = 30,
          windowsize = c(1600, 1000), zoom = .6,
          water = TRUE, waterdepth = 0, wateralpha = 0.35, watercolor = "lightblue",
          waterlinecolor = "white", waterlinealpha = 0.5, solid = FALSE)

# Add cruise track
add_gps_to_rayshader(
  dem.ras,
  nav.sub$lat,
  nav.sub$long,
  nav.sub$alt,
  line_width = 1.5,
  lightsaber = TRUE,
  colour = "blue",
  zscale = 20,
  ground_shadow = TRUE
)

# render_label(dem.ras, x = 500, y = 700, z =1000, zscale = 50,  textcolor = "white", linecolor = "white",
#              text = "Test", relativez = FALSE, textsize = 2, linewidth = 5)
#
# # hard.labels <- latlong_to_rayshader_coords(dem.ras, hard.bottom$lat, hard.bottom$long) %>%
# #   mutate(label = "Hard",
# #          z = 1000)
#
# x = latlong_to_rayshader_coords(dem.ras, nav.sub$lat, nav.sub$long)
#
# rgl::rgl.clear()
#
# montshadow = ray_shade(montereybay, zscale = 50, lambert = FALSE)
# montamb = ambient_shade(montereybay, zscale = 50)
# montereybay %>%
#   sphere_shade(zscale = 10, texture = "imhof1") %>%
#   add_shadow(montshadow, 0.5) %>%
#   add_shadow(montamb, 0) %>%
#   plot_3d(montereybay, zscale = 50, fov = 0, theta = -45, phi = 45,
#           windowsize = c(1000, 800), zoom = 0.75,
#           water = TRUE, waterdepth = 0, wateralpha = 0.5, watercolor = "lightblue",
#           waterlinecolor = "white", waterlinealpha = 0.5)
#
# rgl::rgl.clear()
#
# montereybay %>%
#   sphere_shade(zscale = 10, texture = "imhof1") %>%
#   add_shadow(montshadow, 0.5) %>%
#   add_shadow(montamb,0) %>%
#   plot_3d(montereybay, zscale = 50, fov = 0, theta = -100, phi = 30, windowsize = c(1000, 800), zoom = 0.6,
#           water = TRUE, waterdepth = 0, waterlinecolor = "white", waterlinealpha = 0.5,
#           wateralpha = 0.5, watercolor = "lightblue")
#
# render_label(montereybay, x = 350, y = 160, z = 1000, zscale = 50,
#              text = "Moss Landing", textsize = 2, linewidth = 5)
#
# render_scalebar(limits = c(0, 5, 10),label_unit = "km", position = "W", y=50,
#                 scale_length = c(0.33, 1))
#
# render_compass(position = "E")

# Sys.sleep(0.2)
if (render.hi) {
  render_highquality(here("Figs/sd_bay_rayrender.png"),
                     lightdirection = 0, lightaltitude  = 30, clamp_value = 10,
                     samples=200)
} else {
  render_snapshot(here("Figs/sd_bay_rayrender.png"))
}








