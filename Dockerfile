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
RUN R -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("stringi",upgrade="never", version = "1.7.8")'
RUN Rscript -e 'remotes::install_version("yaml",upgrade="never", version = "2.3.5")'
RUN Rscript -e 'remotes::install_version("stringr",upgrade="never", version = "1.4.0")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.7.2")'
RUN Rscript -e 'remotes::install_version("jsonlite",upgrade="never", version = "1.8.0")'
RUN Rscript -e 'remotes::install_version("purrr",upgrade="never", version = "0.3.4")'
RUN Rscript -e 'remotes::install_version("readr",upgrade="never", version = "2.1.2")'
RUN Rscript -e 'remotes::install_version("dplyr",upgrade="never", version = "1.0.9")'
RUN Rscript -e 'remotes::install_version("tidyr",upgrade="never", version = "1.2.0")'
RUN Rscript -e 'remotes::install_version("shinyjs",upgrade="never", version = "2.1.0")'
RUN Rscript -e 'remotes::install_version("leaflet",upgrade="never", version = "2.1.1")'
RUN Rscript -e 'remotes::install_version("lubridate",upgrade="never", version = "1.8.0")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("testthat",upgrade="never", version = "3.1.4")'
RUN Rscript -e 'remotes::install_version("spelling",upgrade="never", version = "2.2")'
RUN Rscript -e 'remotes::install_version("shinycustomloader",upgrade="never", version = "0.9.0")'
RUN Rscript -e 'remotes::install_version("shinybusy",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("rio",upgrade="never", version = "0.5.29")'
RUN Rscript -e 'remotes::install_version("plyr",upgrade="never", version = "1.8.7")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.3.3")'
RUN Rscript -e 'remotes::install_version("DT",upgrade="never", version = "0.23")'
RUN Rscript -e 'remotes::install_github("datasketch/shinypanels@e5ea3b4690bd009f3285a76fdb1eb7945c74d253")'
RUN Rscript -e 'remotes::install_github("datasketch/shinyinvoer@dd8178db99cac78f0abbd236e83e07bf1f22ba18")'
RUN Rscript -e 'remotes::install_github("datasketch/parmesan@d361f2047a6bb366a0adc271f0e264b62bd1e6e8")'
RUN Rscript -e 'remotes::install_github("datasketch/geodata@b5b2b9f7f53af5c2457f5a3ad4adabe19c0a618c")'
RUN Rscript -e 'remotes::install_github("rpruim/leaflethex@47e7328c0a19271e76f627f35b43fb1187e2dbef")'
RUN Rscript -e 'remotes::install_github("datasketch/homodatum@6993e3f907579fc72cbbf605d1dd1184330f451b")'
RUN Rscript -e 'remotes::install_github("datasketch/hgchmagic@87a138b59fbc52ec6cdc8970f4d6a17da39914f7")'
RUN Rscript -e 'remotes::install_github("datasketch/dsmodules@5e9a9860ae27aad2cbecf3492be5eab1545e5ff5")'
RUN Rscript -e 'remotes::install_github("datasketch/dsvizopts@4d3819ec343f80342308f5cc0974a86e1c515a61")'
RUN Rscript -e 'remotes::install_github("datasketch/dsvizprep@73b3fba1fed6c8b84d07b15d82c2552aa93a6092")'
RUN Rscript -e 'remotes::install_github("rstudio/chromote@e1d2997932671642d12bef0b4c58611e322035c7")'

ARG CKAN_URL
RUN echo ckanUrl=${CKAN_URL} > .Renviron \
    && echo CHROMOTE_CHROME=/usr/bin/vivaldi >> .Renviron


USER root
EXPOSE 3838


CMD R -e "options('shiny.port'=3838,shiny.host='0.0.0.0'); cdmx.shapes::run_app()"
