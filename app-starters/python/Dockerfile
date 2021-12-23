# Build
FROM python:3 as build
COPY ./ /build/
WORKDIR /build
RUN pip install --no-cache-dir -r /build/requirements.txt

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
FROM gcr.io/distroless/python3:latest
COPY --from=linter /app/ /app/
WORKDIR /app
# Put entrypoint command below, cannot be empty
CMD [""]
