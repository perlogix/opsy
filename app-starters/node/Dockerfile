# Build
FROM node:latest as build
WORKDIR /build
COPY ./ /build/
RUN npm install && npm audit --fix && npm cache clean --force \
    npm run build && npm prune --production

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
FROM gcr.io/distroless/nodejs:latest
COPY --from=security /app/ /app/
WORKDIR /app
# Put entrypoint command below, cannot be empty
CMD [""]
