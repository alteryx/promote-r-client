library("devtools")

# build the documentation (Rd files)
devtools::document()

# build the package
devtools::build()

# test the package
devtools::check_cran("../promote_0.1.0.tar.gz")
devtools::release_checks()
