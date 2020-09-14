source("~/.Rprofile")

## This makes sure that R loads the workflowr package
## automatically, everytime the project is loaded
if (requireNamespace("workflowr", quietly = TRUE)) {
message("Loading .Rprofile for the current workflowr project")
library("workflowr")
} else {
message("workflowr package not installed, please run install.packages(\"workflowr\") to use the workflowr functions")
}
source("renv/activate.R")

if (requireNamespace("jetpack", quietly=TRUE)) {
  jetpack::load()
} else {
  message("Install Jetpack to use a virtual environment for this project")
}
