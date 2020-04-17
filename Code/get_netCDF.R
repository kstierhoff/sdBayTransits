dem.name <- here::here("Data/netCDF/san_diego_13_mhw_2012.nc")

dem.df <- tidync(dem.name) %>%
  hyper_filter(lon = between(lon, -117.3, -117.15),
               lat = between(lat, 32.62, 32.8)) %>%
  hyper_tibble() %>%
  select(lon, lat, z = Band1)

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

# Sys.sleep(0.2)
if (render.hi) {
  render_highquality(here("Figs/sd_bay_rayrender.png"),
                     lightdirection = 0, lightaltitude  = 30, clamp_value = 10,
                     samples=200)
} else {
  render_snapshot(here("Figs/sd_bay_rayrender.png"))
}








