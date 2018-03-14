
lgit <- function(gitstr){
    withr::with_libpaths(new='R/x86_64-pc-linux-gnu-library/3.4/',devtools::install_github(gitstr))
}
dir.create('R/x86_64-pc-linux-gnu-library/3.4/',recursive=TRUE,showWarnings=FALSE)
lgit('sjmgarnier/viridisLite')
lgit('sjmgarnier/viridis')

install.packages(c("tidyverse","caret","corrr","doMC","rsample","recipes","glmnet","rpart","ranger","yardstick"),dep=TRUE,repos='http://cran.r-project.org')



