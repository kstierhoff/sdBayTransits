# Lasker data

laskerURL <- URLencode("https://coastwatch.pfeg.noaa.gov/erddap/tabledap/fsuNoaaShipWTEG.csv0?time%2Clatitude%2Clongitude%2Cflag&time%3E=2006-01-19T21%3A45%3A00Z&time%3C=2020-01-26T21%3A45%3A00Z&latitude%3E=32.626574&latitude%3C=32.738634&longitude%3E=242.727805&longitude%3C=242.859503&flag=~%22ZZZ.*%22")

# Download and parse ERDDAP nav data
nav.temp <- data.frame(read.csv(laskerURL, header = F,
                                row.names = NULL, skip = 0))

names(nav.temp) <- c("time","lat","long","flag")

# Filter to remove bad SST values
nav.temp <- nav.temp %>%
  select(-flag) %>%
  mutate(long     = long - 360,
         datetime = ymd_hms(time)) %>%
  arrange(datetime)

time.diff <- as.numeric(diff(nav.temp$datetime))/60/24

cruise.breaks <- as.numeric(nav.temp$datetime[c(1, which(time.diff > 2))])

nav.temp <- nav.temp %>%
  mutate(cruise = cut(as.numeric(datetime), cruise.breaks, include.lowest = TRUE, labels = FALSE))

nav.summ <- nav.temp %>%
  group_by(cruise) %>%
  summarise(start.date = min(datetime),
            end.date = max(datetime)) %>%
  filter(month(start.date) > 3, month(start.date) < 10)

nav.temp <- left_join(nav.temp, nav.summ) %>%
  filter(!is.na(start.date)) %>%
  mutate(vessel.name = "Lasker")

rl.plot <- ggplot(nav.temp, aes(long, lat)) +
  geom_path() +
  facet_wrap(~factor(start.date)) +
  coord_map()

write.csv(nav.summ, file = here::here("Output", "lasker_summary.csv"), quote = FALSE, row.names = FALSE)

nav <- nav.temp

# Shimada data

shimadaURL <- URLencode("https://coastwatch.pfeg.noaa.gov/erddap/tabledap/fsuNoaaShipWTED.csv0?time%2Clatitude%2Clongitude%2Cflag&time%3E=2006-01-19T21%3A45%3A00Z&time%3C=2020-01-26T21%3A45%3A00Z&latitude%3E=32.626574&latitude%3C=32.738634&longitude%3E=242.727805&longitude%3C=242.859503&flag=~%22ZZZ.*%22")

# Download and parse ERDDAP nav data
nav.temp <- data.frame(read.csv(shimadaURL, header = F,
                                row.names = NULL, skip = 0))

names(nav.temp) <- c("time","lat","long","flag")

# Filter to remove bad SST values
nav.temp <- nav.temp %>%
  select(-flag) %>%
  mutate(long     = long - 360,
         datetime = ymd_hms(time)) %>%
  arrange(datetime)

time.diff <- as.numeric(diff(nav.temp$datetime))/60/24

cruise.breaks <- as.numeric(nav.temp$datetime[c(1, which(time.diff > 2))])

nav.temp <- nav.temp %>%
  mutate(cruise = cut(as.numeric(datetime), cruise.breaks, include.lowest = TRUE, labels = FALSE))

nav.summ <- nav.temp %>%
  group_by(cruise) %>%
  summarise(start.date = min(datetime),
            end.date = max(datetime)) %>%
  filter(month(start.date) > 3, month(start.date) < 10)

nav.temp <- left_join(nav.temp, nav.summ) %>%
  filter(!is.na(start.date)) %>%
  mutate(vessel.name = "Shimada")

sh.plot <- ggplot(nav.temp, aes(long, lat)) +
  geom_path() +
  facet_wrap(~factor(start.date)) +
  coord_map()

write.csv(nav.summ, file = here::here("Output", "shimada_summary.csv"), quote = FALSE, row.names = FALSE)

# Combine vessel data
nav <- bind_rows(nav, nav.temp)

# bbox <- list(
#   p1 = list(long = -117.2723, lat = 32.62657),
#   p2 = list(long = -117.15, lat = 32.721)
# )
#
# # bbox <- list(
# #   p1 = list(long = -122.522, lat = 37.707),
# #   p2 = list(long = -122.354, lat = 37.84)
# # )
#
# get_usgs_elevation_data <- function(bbox, size = "400,400", file = NULL,
#                                     sr_bbox = 4326, sr_image = 4326) {
#   require(httr)
#
#   # TODO - validate inputs
#
#   url <- parse_url("https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer/exportImage")
#   res <- GET(
#     url,
#     query = list(
#       bbox = paste(bbox$p1$long, bbox$p1$lat, bbox$p2$long, bbox$p2$lat,
#                    sep = ","),
#       bboxSR = sr_bbox,
#       imageSR = sr_image,
#       size = size,
#       format = "tiff",
#       pixelType = "F32",
#       noDataInterpretation = "esriNoDataMatchAny",
#       interpolation = "+RSP_BilinearInterpolation",
#       f = "json"
#     )
#   )
#
#   if (status_code(res) == 200) {
#     body <- content(res, type = "application/json")
#     # TODO - check that bbox values are correct
#     # message(jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE))
#
#     img_res <- GET(body$href)
#     img_bin <- content(img_res, "raw")
#     if (is.null(file))
#       file <- tempfile("elev_matrix", fileext = ".tif")
#     writeBin(img_bin, file)
#     message(paste("image saved to file:", file))
#   } else {
#     warning(res)
#   }
#   invisible(file)
# }
#
# define_image_size <- function(bbox, major_dim = 400) {
#   # calculate aspect ration (width/height) from lat/long bounding box
#   aspect_ratio <- abs((bbox$p1$long - bbox$p2$long) / (bbox$p1$lat - bbox$p2$lat))
#   # define dimensions
#   img_width <- ifelse(aspect_ratio > 1, major_dim, major_dim*aspect_ratio) %>% round()
#   img_height <- ifelse(aspect_ratio < 1, major_dim, major_dim/aspect_ratio) %>% round()
#   size_str <- paste(img_width, img_height, sep = ",")
#   list(height = img_height, width = img_width, size = size_str)
# }
#
# image_size <- define_image_size(bbox, major_dim = 600)
#
# # download elevation data
# elev_file <- file.path("sd-elevation.tif")
# get_usgs_elevation_data(bbox, size = image_size$size, file = elev_file,
#                         sr_bbox = 4326, sr_image = 4326)
#
# # load elevation data
# elev_img <- raster::raster(elev_file)
# elev_matrix <- matrix(
#   raster::extract(elev_img, raster::extent(elev_img), buffer = 1000),
#   nrow = ncol(elev_img), ncol = nrow(elev_img)
# )
#
# # calculate rayshader layers
# ambmat <- ambient_shade(elev_matrix, zscale = 30)
# raymat <- ray_shade(elev_matrix, zscale = 30, lambert = TRUE)
# watermap <- detect_water(elev_matrix)
#
# # plot 2D
# elev_matrix %>%
#   sphere_shade(texture = "imhof4") %>%
#   add_water(watermap, color = "imhof4") %>%
#   add_shadow(raymat, max_darken = 0.5) %>%
#   add_shadow(ambmat, max_darken = 0.5) %>%
#   plot_map()
