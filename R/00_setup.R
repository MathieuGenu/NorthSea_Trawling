# clean environment
rm(list = ls())

# # we suppose geffaeR installed
# if (!("geffaeR" %in% installed.packages())) {
#   install_github()
# } else {
#   library(geffaeR)
# }

#CRAN packages vector
cran_packages <- c(
  "devtools",
  "tidyverse",
  "magrittr",
  "sf",
  "ggthemes",
  "glue",
  "janitor",
  "rmapshaper",
  "gganimate"
)

github_packages <- c(
  NULL
)

github_repository <- c(
  NULL
)

# c_p_n_i : cran packages not installed
c_p_n_i <- cran_packages[!(cran_packages %in% installed.packages())]
g_p_n_i <- which(!(github_packages %in% installed.packages()))


# installation of packages
lapply(c_p_n_i, install.packages, dependencies = TRUE)
lapply(github_repository[g_p_n_i], devtools::install_github , dependencies = TRUE)

#install packages
lapply(c(cran_packages,github_packages), function(x){                                 
  library(x, character.only = TRUE, quietly = TRUE)
})

rm(c_p_n_i, g_p_n_i, cran_packages, github_packages, github_repository)
