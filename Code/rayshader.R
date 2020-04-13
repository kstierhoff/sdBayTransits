# library(tidyverse)
# library(lubridate)
# library(elevatr)
# library(rayshader)
# library(here)
# library(raster)

# Manual TIFF downloads --------------------------------------------------------
# Rayshader Master Class - Data source guides
# https://github.com/tylermorganwall/MusaMasterclass/tree/master/data_source_guides


# GEBCO bathymetry
# https://download.gebco.net/

# Shuttle Radar Topography Mission (SRTM GL1) Global 30m
# https://portal.opentopography.org/raster?opentopoID=OTSRTM.082015.4326.1


sd.gebco.zoom <- raster::raster(here("Data/rayshader_tiffs", "sd_bay_srtm_zoom.tif")) %>%
  raster_to_matrix()

sd.gebco.wide <- raster::raster(here("Data/rayshader_tiffs", "sd_bay_srtm_wide.tif")) %>%
  raster_to_matrix()

# Programmatic TIFF extraction -------------------------------------------------
# elraster <- get_elev_raster(select(nav, x, y), prj = proj.string, z = 10)


# Try different options
#We use another one of rayshader's built-in textures:
sd.gebco.zoom %>%
  sphere_shade(texture = "desert") %>%
  plot_map()

sd.gebco.zoom %>%
  sphere_shade(texture = "desert") %>%
  add_water(detect_water(sd.gebco.zoom), color = "desert") %>%
  plot_map()

sd.gebco.zoom %>%
  sphere_shade(texture = "desert") %>%
  add_water(detect_water(sd.gebco.zoom), color = "desert") %>%
  add_shadow(ray_shade(sd.gebco.zoom, zscale = 3), 0.5) %>%
  add_shadow(ambient_shade(sd.gebco.zoom), 0) %>%
  plot_3d(sd.gebco.zoom, zscale = 4, fov = 0, theta = -10, zoom = 0.75, phi = 30, windowsize = c(1000, 800))

# Sys.sleep(0.2)
if (render.hi) {
  render_highquality(here("Figs/sd_bay_rayrender.png"),
                   lightdirection = 0, lightaltitude  = 30, clamp_value = 10,
                   samples=200, clear=TRUE)
} else {
  render_snapshot(here("Figs/sd_bay_rayrender.png"), clear=TRUE)
}

# calculate rayshader layers
ambmat <- ambient_shade(sd.gebco.zoom, zscale = 30)
raymat <- ray_shade(sd.gebco.zoom, zscale = 30, lambert = TRUE)
watermap <- detect_water(sd.gebco.zoom)

# plot 2D
sd.gebco.zoom %>%
  sphere_shade(texture = "bw") %>%
  # add_water(detect_water(sd.gebco.zoom), color = "desert") %>%
  add_shadow(raymat, max_darken = 0.5) %>%
  # plot_map()
  plot_3d(sd.gebco.zoom, zscale = 4, fov = 0, theta = -10, phi = 30,
          windowsize = c(1000, 800), zoom = 0.75,
          water = FALSE, waterdepth = 0, wateralpha = 0.40, watercolor = "lightblue",
          waterlinecolor = "white", waterlinealpha = 0.5)



if (render.hi){
  render_highquality(here("Figs/sd_bay_rayrender_bw.png"),
                   lightdirection = 0, lightaltitude  = 30, clamp_value = 10,
                   samples=200, clear=TRUE)
} else {
  render_snapshot(here("Figs/sd_bay_rayrender_bw.png"), clear=TRUE)
}
