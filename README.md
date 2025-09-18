# Digestive

[![CI](https://github.com/kvist-no/digestive/workflows/Rust/badge.svg)](https://github.com/kvist-no/digestive/actions)

An app for sending a preconfigured gRPC command to trigger daily email digest generation. Purpose built to be run as a CronJob in a Kubernetes cluster with Sentry monitoring.

## Why Rust?

- I wanted to try it out
- Low memory and CPU requirements
- Perhaps not the smartest choice in hindsight, but can easily be rewritten to Node.js or something else

## How It Works

The service performs these steps:
1. Reports job start to Sentry for monitoring
2. Connects to your notification service via gRPC
3. Sends a command to trigger digest email generation
4. Reports success/failure status back to Sentry
5. Exits cleanly

## Configuration

Configure the service using these environment variables:

### Required Variables
```env
# Which environment we're running in (used for Sentry monitoring)
ENVIRONMENT=staging

# Sentry Cron monitor URL for status reporting
CRON_URL=https://oxxxxxxxxxxxxxxxx.ingest.de.sentry.io/api/xxxxxxxxxxxxxxxx/cron/digest-trigger/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/

# The gRPC endpoint of your notification service
NOTIFICATION_SERVICE_URL=https://notification.init.svc.cluster.local:8080

# Log level
RUST_LOG=info
```

### Optional Variables (with defaults)
```env
# Who is sending the command (shown in logs and potentially forwarded)
COMMAND_FROM="Kubernetes Debrief Trigger CronJob"

# The specific command to send to the notification service
COMMAND_COMMAND="SendDigestEmailsCommand"

# JSON data payload for the command
COMMAND_DATA="{\"template\":\"daily-digest\"}"

# Optional requester identifier
COMMAND_REQUESTER=""
```

## Local Development & Testing

### Prerequisites
- Rust 1.70+ (`rustup` recommended)
- Protocol Buffers compiler (`protoc`)

On macOS:
```bash
brew install protobuf
```

### Build and Run
```bash
cargo build

export ENVIRONMENT=development
export CRON_URL=https://your-sentry-monitor-url
export NOTIFICATION_SERVICE_URL=http://localhost:50051
export RUST_LOG=info

cargo run
```

### Testing
```bash
cargo test
```

## Monitoring Your CronJob
- Check CronJob status: `kubectl get cronjobs`
- View recent job runs: `kubectl get jobs`
- Check logs: `kubectl logs -l job-name=digestive-daily-<timestamp>`
- Monitor in Sentry for cron job health and failure alerts

## Deployment as Kubernetes CronJob

This service is designed to run as a Kubernetes CronJob. Here's an example configuration:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: digestive-daily
  namespace: your-namespace
spec:
  # Run every day at 8 AM UTC
  schedule: "0 8 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: digestive
            image: your-registry/digestive:latest
            env:
            - name: ENVIRONMENT
              value: "staging"
            - name: CRON_URL
              valueFrom:
                secretKeyRef:
                  name: digestive-secrets
                  key: sentry-cron-url
            - name: NOTIFICATION_SERVICE_URL
              value: "https://notification.init.svc.cluster.local:8080"
            - name: RUST_LOG
              value: "info"
            - name: COMMAND_DATA
              value: '{"template":"daily-digest"}'
            resources:
              requests:
                memory: "32Mi"
                cpu: "10m"
              limits:
                memory: "64Mi"
                cpu: "100m"
          # Clean up completed jobs after 3 successful runs and 1 failed run
          successfulJobsHistoryLimit: 3
          failedJobsHistoryLimit: 1
```

### Kubernetes Secret for Sentry URL
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: digestive-secrets
  namespace: your-namespace
type: Opaque
stringData:
  sentry-cron-url: "https://oxxxxxxxxxxxxxxxx.ingest.de.sentry.io/api/xxxxxxxxxxxxxxxx/cron/digest-trigger/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/"
```
