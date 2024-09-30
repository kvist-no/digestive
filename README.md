# CronJob sending gRPC message to `notification` service to trigger creating email digest

Configuration options through env vars

```env
# Which environment we're running in (for Sentry monitor)
ENVIRONMENT=
# Sentry Cron monitor URL for cURL
CRON_URL=
# What the URL of the notification service which receives the gRPC call is
NOTIFICATION_SERVICE_URL=

# gRPC Command parameters (with defaults)
COMMAND_FROM=Kubernetes Debrief Trigger CronJob
COMMAND_COMMAND=SendDigestEmailsCommand
COMMAND_DATA={\"template\":\"daily-digest\"}
COMMAND_REQUESTER=
```