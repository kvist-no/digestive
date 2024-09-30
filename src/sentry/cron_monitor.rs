use anyhow::Result;

#[derive(Debug)]
pub enum CronJobStatus {
    InProgress,
    Ok,
    Error,
}

#[derive(Copy, Clone)]
pub struct CronMonitor<'a> {
    pub cron_url: &'a str,
    pub environment: &'a str,
}

impl CronMonitor<'_> {
    pub async fn report(self, job_status: CronJobStatus) -> Result<()> {
        let status_string = match job_status {
            CronJobStatus::Ok => "ok",
            CronJobStatus::InProgress => "in_progress",
            CronJobStatus::Error => "error"
        };

        reqwest::get(
            format!(
                "{}?environment={}&status={}",
                self.cron_url, self.environment, status_string
            )
        ).await?;

        Ok(())
    }
}