# Save figures
if (save.figs) {
  # Save individual plots
  ggsave(rl.plot, filename = here::here("Figs", "lasker_plot.png"), width = 8, height = 8)
  ggsave(sh.plot, filename = here::here("Figs", "shimada_plot.png"), width = 8, height = 8)

  map.center <- c(mean(range(nav$long)), mean(range(nav$lat)))

  map <- get_googlemap(c(mean(range(nav$long)), mean(range(nav$lat))), maptype = "satellite", zoom = 12)

  saveRDS(map, here::here("Data", "sd_bay_ggmap.rds"))

  # Create land object for plotting
  usa <- map_data("usa")

  # Convert to sf
  nav.sf <- nav %>%
    sf::st_as_sf(coords = c("long","lat"), crs = 4326)

  # Get map boundaries for plotting
  map.bounds <- nav.sf %>%
    sf::st_bbox()

  # Plot all transits
  all.plot <- ggmap(map) +
    # geom_polygon(data = usa, aes(x = long, y = lat, group = group)) +
    geom_path(data = nav, aes(long, lat, group = cruise, colour = factor(cruise))) +
    facet_wrap(~vessel.name) +
    labs(x = "Longitude", y = "Latitude") +
    coord_sf(crs = 4326, # CA Albers Equal Area Projection
             xlim = c(map.bounds["xmin"], map.bounds["xmax"]),
             ylim = c(map.bounds["ymin"], map.bounds["ymax"])) +
    theme_bw() +
    theme(legend.position = "NONE")

  ggsave(all.plot, filename = here::here("Figs", "both_plots.png"), width = 16, height = 8)
}
