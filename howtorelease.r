library("devtools")
# build the documentation (Rd files)
devtools::load_all()
devtools::document()

# test the package
devtools::check()
devtools::check_man()
# devtools::check_cran()
# devtools::release_checks()

# build the package
devtools::build(binary = TRUE)
# f <- devtools::build()

# install
# devtools::install_local(f)