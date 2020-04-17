# Lasker data

laskerURL <- URLencode("https://coastwatch.pfeg.noaa.gov/erddap/tabledap/fsuNoaaShipWTEG.csv0?time%2Clatitude%2Clongitude%2Cflag&time%3E=2006-01-19T21%3A45%3A00Z&time%3C=2020-01-26T21%3A45%3A00Z&latitude%3E=32.626574&latitude%3C=32.738634&longitude%3E=242.727805&longitude%3C=242.859503&flag=~%22ZZZ.*%22")

# Download and parse ERDDAP nav data
nav.temp <- data.frame(read.csv(laskerURL, header = F,
                                row.names = NULL, skip = 0))

names(nav.temp) <- c("time","lat","long","flag")

# Filter to remove bad SST values
nav.temp <- nav.temp %>%
  dplyr::select(-flag) %>%
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
  dplyr::select(-flag) %>%
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

write.csv(nav.summ, file = here::here("Output", "shimada_summary.csv"), quote = FALSE, row.names = FALSE)

# Combine vessel data
nav <- bind_rows(nav, nav.temp)

save(nav, file = here("Data/nav_data.Rdata"))
