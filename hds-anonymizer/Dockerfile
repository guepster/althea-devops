# Dockerfile durci type - multi-stage, non-root (CIS Docker Benchmark)
FROM python:3.12-slim-bookworm AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim-bookworm
LABEL org.opencontainers.image.title="hds-anonymizer" \
      org.opencontainers.image.vendor="Althea Systems / Aleeph" \
      org.opencontainers.image.licenses="Proprietary"
COPY --from=builder /install /usr/local
COPY main.py /app/main.py
RUN useradd -u 1000 -m anon
USER 1000
WORKDIR /app
ENTRYPOINT ["python", "/app/main.py"]
