library(raster)
library(tidyverse)
library(tidync)
library(here)
library(rayshader)


filename <- here::here("Data/netCDF/san_diego_13_mhw_2012.nc")

tmp.tibble <- tidync(filename) %>%
  hyper_filter(lon = between(lon, -117.3, -117.15),
               lat = between(lat, 32.62, 32.8)) %>%
  hyper_tibble() %>%
  select(lon, lat, z = Band1)

tmp.raster <- raster::rasterFromXYZ(tmp.tibble)

raster::crs(tmp.raster) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

tmp.raster.red <- raster::aggregate(tmp.raster, fact = 4)

tmp.mat <- raster_to_matrix(tmp.raster)

tmp.mat.red <- raster_to_matrix(tmp.raster.red)

tmp.mat.red %>%
sphere_shade(texture = "desert") %>%
  plot_map()


# Subset nav
nav.sub <- nav %>%
  filter(cruise == 30) %>%
  mutate(alt = 1)

rgl::rgl.clear()

# Plot 3D
tmp.mat.red %>%
  sphere_shade(texture = "imhof4") %>%
  add_water(detect_water(tmp.mat.red), color = "imhof4") %>%
  add_shadow(ray_shade(tmp.mat.red, zscale = 3), 0.5) %>%
  add_shadow(ambient_shade(tmp.mat.red), 0) %>%
plot_3d(tmp.mat.red, zscale = 4, fov = 0, theta = 45, phi = 30,
        windowsize = c(1000, 800), zoom = .5,
        water = TRUE, waterdepth = 0, wateralpha = 0.35, watercolor = "lightblue",
        waterlinecolor = "white", waterlinealpha = 0.5)

# Add cruise track
add_gps_to_rayshader(
  tmp.raster.red,
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
                     samples=200, clear=TRUE)
} else {
  render_snapshot(here("Figs/sd_bay_rayrender.png"), clear=TRUE)
}








