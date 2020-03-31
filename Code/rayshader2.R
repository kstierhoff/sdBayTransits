library(elevatr)
library(tidyverse)
library(lubridate)

locs <- data.frame(x = -117.205699, y = 32.719154)
proj.string <- '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'

laskerURL <- URLencode("https://coastwatch.pfeg.noaa.gov/erddap/tabledap/fsuNoaaShipWTEG.csv0?time%2Clatitude%2Clongitude%2Cflag&time%3E=2006-01-19T21%3A45%3A00Z&time%3C=2020-01-26T21%3A45%3A00Z&latitude%3E=32.680161&latitude%3C=32.738634&longitude%3E=242.727805&longitude%3C=242.859503&flag=~%22ZZZ.*%22")

# Download and parse ERDDAP nav data
nav <- data.frame(read.csv(laskerURL, header = F, 
                                row.names = NULL, skip = 0))

names(nav) <- c("time","y","x","flag")

# Filter to remove bad SST values
nav <- nav %>%
  select(-flag) %>% 
  mutate(x     = x - 360,
         datetime = ymd_hms(time)) %>% 
  arrange(datetime)

x <- get_elev_raster(select(nav, x, y), prj = proj.string, z = 10)

# Load rayshader
# library(rayshader)

#And convert it to a matrix:
elmat = raster_to_matrix(x)

#We use another one of rayshader's built-in textures:
elmat %>%
  sphere_shade(texture = "desert") %>%
  plot_map()

elmat %>%
  sphere_shade(texture = "desert") %>%
  add_water(detect_water(elmat), color = "desert") %>%
  plot_map()

elmat %>%
  sphere_shade(texture = "desert") %>%
  add_water(detect_water(elmat), color = "desert") %>%
  add_shadow(ray_shade(elmat, zscale = 3), 0.5) %>%
  add_shadow(ambient_shade(elmat), 0) %>%
  plot_3d(elmat, zscale = 10, fov = 0, theta = 135, zoom = 0.75, phi = 45, windowsize = c(1000, 800))
Sys.sleep(0.2)
render_snapshot(clear=TRUE)

# calculate rayshader layers
# ambmat <- ambient_shade(elmat, zscale = 30)
raymat <- ray_shade(elmat, zscale = 30, lambert = TRUE)
watermap <- detect_water(elmat)

# plot 2D
elmat %>%
  sphere_shade(texture = "imhof4") %>%
  # add_water(watermap, color = "imhof4") %>%
  add_shadow(raymat, max_darken = 0.5) %>%
  # add_shadow(ambmat, max_darken = 0.5) %>%
  # plot_map()

plot_3d(elmat, zscale = 10, fov = 0, theta = -45, phi = 45, 
        windowsize = c(1000, 800), zoom = 0.75,
        water = TRUE, waterdepth = 0, wateralpha = 0.40, watercolor = "lightblue",
        waterlinecolor = "white", waterlinealpha = 0.5)

render_highquality(lightdirection = 0, lightaltitude  = 30, clamp_value = 10, 
                   samples=200, clear=TRUE)
