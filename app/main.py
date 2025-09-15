from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
import uvicorn
import os
import time
import json
import logging
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from prometheus_client import start_http_server
import threading
import requests
import pickle
import numpy as np

LOG = logging.getLogger("uvicorn")
logging.basicConfig(level=logging.INFO)

# Prometheus metrics
REQUEST_COUNT = Counter('aiops_requests_total', 'Total number of prediction requests')
REQUEST_LATENCY = Histogram('aiops_request_latency_seconds', 'Latency for prediction requests')
DRIFT_COUNT = Counter('aiops_drift_detected_total', 'Number of drift detections')

MODEL_PATH = os.getenv('MODEL_PATH', '/app/model/model.pkl')
GITLAB_RETRAIN_WEBHOOK = os.getenv('GITLAB_RETRAIN_WEBHOOK')
DRIFT_THRESHOLD = float(os.getenv('DRIFT_THRESHOLD', '0.3'))

class InputData(BaseModel):
    features: list

app = FastAPI(title="aiops-quality-project inference")

# Model wrapper
class Model:
    def __init__(self, path):
        self.path = path
        self._load()

    def _load(self):
        try:
            with open(self.path, 'rb') as f:
                self.obj = pickle.load(f)
            LOG.info(f"Loaded model from {self.path}")
        except Exception as e:
            LOG.warning(f"Could not load model at {self.path}: {e}. Using dummy fallback model.")
            self.obj = None

    def predict(self, features):
        arr = np.array(features, dtype=float)
        if self.obj is None:
            return float(arr.sum())
        if hasattr(self.obj, 'predict'):
            return self.obj.predict(arr.reshape(1, -1)).tolist()[0]
        return float(arr.sum())

model = Model(MODEL_PATH)

class DriftDetector:
    def __init__(self):
        self.ref_mean = None
        self.ref_std = None
        self.n_ref = 0

    def update_reference(self, features):
        arr = np.array(features, dtype=float)
        if self.ref_mean is None:
            self.ref_mean = arr
            self.ref_std = np.zeros_like(arr)
            self.n_ref = 1
        else:
            self.n_ref += 1
            self.ref_mean = self.ref_mean + (arr - self.ref_mean) / self.n_ref
            self.ref_std = np.sqrt(((self.n_ref - 1) * (self.ref_std ** 2) + (arr - self.ref_mean) ** 2) / self.n_ref)

    def check_drift(self, features):
        if self.ref_mean is None:
            return False, 0.0
        arr = np.array(features, dtype=float)
        diff = np.abs(arr - self.ref_mean)
        norm = (self.ref_std + 1e-6)
        z = diff / norm
        score = float(np.mean(z))
        return score > DRIFT_THRESHOLD, score

detector = DriftDetector()

@app.on_event("startup")
def startup_event():
    metrics_port = int(os.getenv('METRICS_PORT', '8001'))
    threading.Thread(target=lambda: start_http_server(metrics_port), daemon=True).start()
    LOG.info(f"Prometheus metrics server started on :{metrics_port}")

@app.get('/health')
def health():
    return {"status": "ok"}

@app.post('/predict')
def predict(input: InputData, background_tasks: BackgroundTasks):
    start = time.time()
    REQUEST_COUNT.inc()
    try:
        LOG.info(f"REQUEST INPUT: {input.json()}")
        prediction = model.predict(input.features)
        LOG.info(f"PREDICTION: {prediction}")
        background_tasks.add_task(async_check_drift, input.features)
        return {"prediction": prediction}
    finally:
        REQUEST_LATENCY.observe(time.time() - start)

def async_check_drift(features):
    detector.update_reference(features)
    drift, score = detector.check_drift(features)
    if drift:
        DRIFT_COUNT.inc()
        LOG.warning(f"Drift detected — score={score}")
        print("Drift detected")
        if GITLAB_RETRAIN_WEBHOOK:
            try:
                requests.post(GITLAB_RETRAIN_WEBHOOK, json={"reason": "drift_detected", "score": score}, timeout=5)
                LOG.info("Triggered retrain webhook")
            except Exception as e:
                LOG.warning(f"Failed to call retrain webhook: {e}")

@app.get('/metrics')
def metrics():
    return generate_latest()

if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=int(os.getenv('PORT', 8000)))
