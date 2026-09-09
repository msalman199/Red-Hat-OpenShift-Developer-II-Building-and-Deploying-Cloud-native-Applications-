# Webhook Pipeline Demo

This is a demonstration application for OpenShift webhook-triggered pipelines.

## Features

- **Automatic Deployment**: Code changes trigger automatic builds and deployments
- **GitHub Integration**: Webhooks automatically trigger pipelines on push events
- **Health Monitoring**: Built-in health and version endpoints
- **Container Ready**: Dockerized application ready for OpenShift deployment

## Endpoints

- `/` - Main application endpoint with feature information
- `/health` - Health check endpoint with system metrics
- `/version` - Version information and build details

## Version History

- **v2.0.0**: Added version endpoint and enhanced features
- **v1.0.0**: Initial release with basic functionality

## CI/CD Pipeline

This application uses Tekton pipelines triggered by GitHub webhooks:

1. **Source Fetch**: Pulls latest code from GitHub
2. **Build**: Creates container image using Buildah
3. **Deploy**: Deploys to OpenShift and exposes service

## Testing

Run the test script to verify functionality:

```bash
