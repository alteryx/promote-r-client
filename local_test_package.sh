# Rscript howtorelease.R
PARENT="$(pwd)"

cd ../

R CMD install ./promote_*.tar.gz

cd $PARENT
Rscript tests/test.R