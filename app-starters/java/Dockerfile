# Build
FROM maven:3.8-openjdk-11-slim as build
COPY ./ /build/
WORKDIR /build
RUN mvn clean install

# Linter
FROM github/super-linter:latest as linter
COPY --from=build /build/ /app/
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
FROM gcr.io/distroless/java:11
COPY --from=security /build/*.jar /app/
WORKDIR /app
EXPOSE 8080 8080
# Put entrypoint command below, cannot be empty
ENTRYPOINT [""]
