# Rscript howtorelease.R
PARENT="$(pwd)"

cd ../

R CMD install ./promote_*.tgz

cd $PARENT
./tests/run_tests.sh