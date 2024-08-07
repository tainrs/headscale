# This Dockerfile is used to create a Docker image for Headscale
# It pulls an upstream image, sets up the environment, installs dependencies,
# installs Plex Media Server, and prepares the configuration.

# Define arguments for the upstream image and its digest for AMD64 architecture
ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_AMD64

# Use the upstream image as the base image for this Dockerfile
FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_AMD64}

# Define arguments and environment variables
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} \
    SERVER_URL="https://server.example.com:443"

# Update the package list and install required dependencies
RUN apk add --no-cache libintl sqlite-libs icu-libs yq

ARG VERSION
ARG PACKAGE_VERSION=${VERSION}

# Create a directory for the application binary and download Headscale
RUN set -e ;\
    mkdir "${APP_DIR}/bin" ;\
    curl -fsSL -o "${APP_DIR}/bin/headscale" "https://github.com/juanfont/headscale/releases/download/v${VERSION}/headscale_${VERSION}_linux_amd64"

# Set the appropriate permissions for the application binary and create the configuration directory
RUN set -e ;\
    chmod +x "${APP_DIR}/bin/headscale" ;\
    mkdir -p /etc/headscale ;\
    mkdir -p /config/headscale
    # touch /config/headscale/db.sqlite

# Download sample configuration file
RUN set -e ;\
    curl -fsSL -o /etc/headscale/config.yaml "https://raw.githubusercontent.com/juanfont/headscale/main/config-example.yaml"

# Create a package_info file with version and author information
RUN echo -e "PackageVersion=${PACKAGE_VERSION}\nPackageAuthor=[tainrs](https://github.com/tainrs)\nUpdateMethod=Docker\nBranch=${SBRANCH}" > "${APP_DIR}/package_info"

# Set appropriate permissions for the application directory
RUN chmod -R u=rwX,go=rX "${APP_DIR}"

# Copy the root directory to the container
COPY root/ /

WORKDIR /config/headscale
