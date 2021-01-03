## tag versions https://github.com/rocker-org/rocker-versioned
FROM rocker/verse:4.0.3

RUN apt-get -y update && apt-get -y --no-install-recommends install libsasl2-dev

## Install additional packages required for the project
RUN Rscript -e 'install.packages("mongolite")'
RUN Rscript -e 'install.packages("tidymodels")'

RUN mkdir /app
