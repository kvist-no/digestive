use anyhow::Result;
use digestive::run;

#[tokio::main]
async fn main() -> Result<()> {
    run().await
}
