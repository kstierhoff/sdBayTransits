library(tidyverse)
library(lubridate)
library(here)
library(janitor)

# EVR file definitions
# https://support.echoview.com/WebHelp/Reference/File_formats/Export_file_formats/2D_Region_definition_file_format.htm#2D_region_definition_file_format

# Read EVR files
tmp <- readLines(here("Data/regions/1204SH_D20120407-SDBAY_CPS.EVR"))

regions <- tmp[grep("^13\\W+", tmp)]

reg.start <- stringr::str_extract_all(tmp[grep("^13\\W+", tmp)], pattern = "\\d{8}\\W\\d{10}")

# Extract values -----------------------------------
# Extract region date/times
reg.times <- as.POSIXct(unlist(stringr::str_extract_all(tmp[grep("^13\\W+", tmp)], pattern = "\\d{8}\\W\\d{10}")),
                        format = "%Y%m%d %H%M%S%OS", tz = "UTC")

# Get region start and end times
reg.starts <- reg.times[seq(1, length(reg.times)-1, 2)]
reg.ends <- reg.times[seq(2, length(reg.times), 2)]

# Get region descriptions

hard.bottom <- data.frame()

for (i in fs::dir_ls(here("Data/regions"), regexp = "*.csv")) {
  filename <-

    tmp <- read_csv(i) %>%
    clean_names() %>%
    mutate(filename = unlist(str_split(basename(i), "_"))[1],
           datetime = ymd_hms(paste(date_m, time_m))) %>%
    rename(lat = lat_m,
           long = lon_m)

  hard.bottom <- bind_rows(hard.bottom, tmp)
}


hard.map <- ggmap(gg.map) +
  geom_point(data = hard.bottom, aes(long, lat, size = dist_m, colour = filename)) +
  theme_bw() +
  coord_map() #+   facet_wrap(~filename)
