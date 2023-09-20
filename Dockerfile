# Establece la imagen base que se esta utilizando. En este caso, se usa una imagen específica que tiene R 4.2, creada por el proyecto rocker.
FROM --platform=linux/amd64 rocker/r-ver:4.2

# Instalacion de dependencias
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/ \
    && echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" > /usr/local/lib/R/etc/Rprofile.site \
    && cp /usr/local/lib/R/etc/Rprofile.site /usr/lib/R/etc/ \
    && apt-get update \
    && apt-get install -y ca-certificates lsb-release wget

# Instalación de Vivaldi y Apache Arrow
RUN wget https://downloads.vivaldi.com/stable/vivaldi-stable_5.5.2805.35-1_amd64.deb \
    && wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb \
    && apt-get update \
    && apt-get install -y ./vivaldi-stable_5.5.2805.35-1_amd64.deb ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb \
    && apt-get clean \
    && rm vivaldi-stable_5.5.2805.35-1_amd64.deb apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb

# Update after adding Apache Arrow repo and then install dependencies
RUN apt-get update && apt-get install -y \
      gdal-bin \
      git-core \
      imagemagick \
      libcurl4-openssl-dev \
      libgdal-dev \
      libgeos-dev \
      libgeos++-dev \
      libgit2-dev \
      libglpk-dev \
      libgmp-dev \
      libicu-dev \
      libpng-dev \
      libproj-dev \
      libssl-dev \
      libxml2-dev \
      make \
      pandoc \
      pandoc-citeproc \
      zlib1g-dev \
      libmagick++-dev \
      libpoppler-cpp-dev \
      libudunits2-dev \
      protobuf-compiler \
      libprotobuf-dev \
      libjq-dev \
      libarrow-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalacion de paquetes de R
RUN R -e 'install.packages(c("remotes", "rgdal", "sp", "stringi", "stringr", "shiny", "jsonlite", "purrr", "readr", "dplyr", "tidyr", "shinyjs", "leaflet", "config", "testthat", "spelling", "fs", "webshot2", "shinycustomloader", "shinybusy", "DT", "markdown"))' \
    && Rscript -e 'remotes::install_github(c("datasketch/dstools", "CamilaAchuri/shinypanels@eeec45b196c99a91ae8033e95b0d52363ff1abc2", "datasketch/shinyinvoer@dd8178db99cac78f0abbd236e83e07bf1f22ba18", "datasketch/parmesan@d361f2047a6bb366a0adc271f0e264b62bd1e6e8", "rstudio/chromote@e1d2997932671642d12bef0b4c58611e322035c7", "dreamRs/d3.format", "datasketch/homodatum", "datasketch/dsmodules@5e9a9860ae27aad2cbecf3492be5e", "datasketch/cdmx-shapes"))'


ARG CKAN_URL
RUN echo ckanUrl=${CKAN_URL} > .Renviron \
    && echo CHROMOTE_CHROME=/usr/bin/vivaldi >> .Renviron


USER root
EXPOSE 3838


CMD R -e "options('shiny.port'=3838,shiny.host='0.0.0.0'); cdmx.shapes::run_app()"
