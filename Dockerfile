
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY model/ model/
COPY app/ app/
RUN python model/train.py

# --- STAGE 2: Runtime  ---

FROM python:3.11-slim AS runtime
WORKDIR /app
COPY --from=builder /app/model/ model/
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ app/
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
