FROM rust:1.87 AS builder
WORKDIR /usr/src/digestive
COPY . .
RUN apt update && apt install -y protobuf-compiler
# --locked builds the committed Cargo.lock instead of resolving the newest
# crates, some of which no longer parse on older toolchains.
RUN cargo install --path . --bin digestive --locked

FROM debian:bookworm-slim

RUN apt update && apt install -y openssl ca-certificates

COPY --from=builder /usr/local/cargo/bin/digestive /usr/local/bin/digestive
CMD ["digestive"]