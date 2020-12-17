source("R/00_setup.R")


# Simplify shape
# NEA_cropped <- NEA %>% 
#   st_as_sf() %>% 
#   st_crop(st_bbox(c(xmin = -20, xmax = 20, ymin = 40, ymax = 75))) %>% 
#   ms_simplify(keep = 0.2)
# 
# st_write(NEA_cropped, "data/shape_land/shape_land_contour.shp")

NEA_cropped <- st_read("data/shape_land/shape_land_contour.shp")

# import trawling data
data <- st_read("data/Recordset_10953Point.shp")

data <- data %>% 
  mutate(lon = as.numeric(as.character(lon)),
         lat = as.numeric(as.character(lat)))


df_trawl <- data %>% 
  as_Spatial() %>% 
  as_tibble() %>%
  select(-coords.x1,-coords.x2)

# get rows of missing values (Hourstrawl = 0)
expanded_trawl <- df_trawl %>% 
  expand(ICESrect, Year, Gear, Datatype) %>% 
  left_join(df_trawl %>% select(-c("lon","lat")), by = c("ICESrect", "Year", "Gear", "Datatype")) 
  
expanded_trawl <- expanded_trawl %>% 
  left_join(df_trawl %>% select(ICESrect, lon, lat) %>% unique() , by = "ICESrect") 

expanded_trawl <- expanded_trawl %>% 
  mutate(Hourstrawl = ifelse(is.na(Hourstrawl), 0, Hourstrawl))



# create gif (traw_by_YGR : trawl by year, Gear and Rect)
traw_by_YGR <- expanded_trawl %>% 
  group_by(ICESrect, lat, lon, Gear, Year) %>% 
  summarize(effort = sum(Hourstrawl)) %>% 
  tibble()

gg_gif <- ggplot() +
  geom_tile(data = traw_by_YGR, aes(x = lon, y = lat, fill = effort)) +
  geom_sf(data = NEA_cropped) +
  facet_grid(.~Gear) +
  scale_fill_viridis_c() +
  coord_sf(xlim = c(-10, 15),
           ylim = c(50, 65)) +
  transition_time(Year) +
  theme_bw() +
  labs(title = 'Year: {frame_time}')


animate(gg_gif, fps = 10, width = 750, height = 450)
anim_save("nations.gif")
