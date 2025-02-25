FROM rust:latest AS builder
WORKDIR /usr/src/digestive
COPY . .
RUN apt update && apt install -y protobuf-compiler
RUN cargo install --path . --bin digestive

FROM debian:bookworm-slim

RUN apt update && apt install -y openssl ca-certificates

COPY --from=builder /usr/local/cargo/bin/digestive /usr/local/bin/digestive
CMD ["digestive"]