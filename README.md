# Opsy

Opsy is a barebones reference to DevSecOps patterns for applications and Linux management.

Quickly bootstrap your Linux servers and applications with hardening basics, security scanning [Trivy](https://github.com/aquasecurity/trivy), Docker image compression [docker-slim](https://github.com/docker-slim/docker-slim), secrets detection [gitleaks](https://github.com/zricethezav/gitleaks) and linting [Super-Linter](https://github.com/github/super-linter).

<div id="top"></div><br>

## Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Configurations](#configurations)
4. [Contributing](#contributing)

<br>

## Overview

`app-starters` - Docker container templates for bootstrapping applications with basic build/test, linting, secrets detection, and security scanning stages.  A basic build-run start.sh script for streamlined local development and small deployments. See start.sh section below.

`vagrant-envs` - General Vagrantfiles for Linux VMs with basic setup, including a [k3s](https://github.com/k3s-io/k3s) environment loaded for local Kubernetes development.

`linux-ops` - Scripts and configurations for basic server setup, updates, cleaning, and basic hardening settings. Linux servers supported are Debian-based, RPM-based, and ClearLinux.

<p align="right">(<a href="#top">back to top</a>)</p><br>

## Getting Started

### app-starter
  - Copy project language files to your project
  - Update Docker build stage to incorporate any changes needed for building and testing your application
  - Include any build-run steps in the start.sh script
  - Update README.md

### start.sh

If docker-slim is installed it will run it after the build to compress your Docker image further. start.sh will generate a build.log incase you missed the terminal output.

To configure Slack messages when builds happen update the following variables, `SLACK_TOKEN` and `SLACK_CHANNELS` in start.sh.

Slack messages will appear as such:

![Slack Message](https://perlogix.com/assets/images/opsy-slack.png "Slack Message")


**Build Docker Container**
```sh
./start.sh build
```

**Run Docker Container**
```sh
./start.sh run
```

**Clean Docker System**
```sh
./start.sh clean
```

**Make Self-Signed Cert**
```sh
./start.sh mkcert
```

**Custom run by uncommenting the function calls at the bottom of the start.sh script.**
```sh
./start.sh
```

### linux-ops
  - Install and execute the install.sh, which will install and run the maintenance.sh, quick-secure.sh, and server-setup.sh scripts on your Linux system.
  - If you only want one of the scripts, copy the main branch's raw file onto your server and execute it.

```sh
curl -LO https://raw.githubusercontent.com/perlogix/opsy/main/linux-ops/install.sh && chmod 0755 ./install.sh && ./install.sh
```

### vagrant-envs
  - Clone repo and cd to vagrant-envs
  - Run `vagrant up`
  - SSH via `vagrant ssh`

<p align="right">(<a href="#top">back to top</a>)</p><br>

## Configurations

The majority of the defaults in the files in the project are meant to be as unopinionated as possible. The server-setup.sh script has the most opinions for setting up a Linux box. Some of the configurations like sysctl might be too aggressive depending on the environment and compliance controls you need. Throughout this project, some of the default sets are not for everyone but should be easy to change with minimal understanding of shell, Linux, and Docker.

### k3s vagrant-env

When starting the vagrant box it will expose an insecure Kubernetes dashboard to your host. You can find all info for accessing the k3s cluster, versions and Dashboard URL in the INFO file generated in the k3s directory and on the vagrant VM under `/vagrant/INFO`.

### install.sh

This script also installs [cmon](https://github.com/perlogix/cmon) if you do not plan to send system informations and metrics to an Elasticsearch cluster this can be removed. If you're interested to learn more you can see more information on the project page.

<p align="right">(<a href="#top">back to top</a>)</p><br>

## Contributing


1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/feature_a`)
3. Commit your Changes (`git commit -m 'Added new feature_a'`)
4. Push to the Branch (`git push origin feature/feature_a`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p><br>