# Build
FROM golang:latest as build

ARG GOOS
WORKDIR /go/src/build
COPY ./ ./
RUN apt-get update && apt-get install \
    -y --no-install-recommends \
    upx && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN make GOOS=${GOOS}

# Linter
FROM github/super-linter:latest as linter
COPY --from=build /go/src/build/ /app/
WORKDIR /app
ENV RUN_LOCAL="true"
ENV VALIDATE_ALL_CODEBASE="true"
ENV LOG_FILE="super-linter.log"
ENV OUTPUT_FOLDER="/app"
ENV DISABLE_ERRORS="true"
ENV SUPPRESS_POSSUM="true"
ENV DEFAULT_WORKSPACE="/app"
ENV GITLEAKS_CONFIG_FILE="gitleaks.toml"
RUN cp -f /app/gitleaks.toml /action/lib/.automation/ && \
    /action/lib/linter.sh

# Security
FROM aquasec/trivy:latest as security
COPY --from=linter /app/ /app/
WORKDIR /app
RUN trivy fs -f table --exit-code 0 --no-progress /app/

# App Container
FROM gcr.io/distroless/base:latest
COPY --from=security /app/ /app/
WORKDIR /app
# Put entrypoint command below, cannot be empty
CMD [""]
