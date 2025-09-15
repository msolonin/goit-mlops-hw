import os
import pickle
from datetime import datetime
import numpy as np
from sklearn.datasets import make_regression
from sklearn.linear_model import LinearRegression

OUT = os.getenv('OUT', 'app/model')
os.makedirs(OUT, exist_ok=True)
model_path = os.path.join(OUT, 'model.pkl')

# Generate synthetic dataset
X, y = make_regression(n_samples=100, n_features=3, noise=0.1, random_state=42)

# Train simple LinearRegression model
reg = LinearRegression()
reg.fit(X, y)

# Save model
with open(model_path, 'wb') as f:
    pickle.dump(reg, f)
print(f"Saved sklearn LinearRegression model to {model_path}")

# Save training metadata
metrics_path = os.path.join(OUT, 'train_metrics.json')
with open(metrics_path, 'w') as f:
    f.write('{"train_samples": 100, "features": 3, "created_at": "%s"}' % datetime.utcnow().isoformat())
print(f"Saved train metrics to {metrics_path}")