import os
import time
import mlflow
import mlflow.sklearn
import prometheus_client
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, log_loss

# Налаштування MLflow
mlflow.set_tracking_uri(os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5000"))
mlflow.set_experiment("iris-experiment")

# Налаштування Prometheus PushGateway
PUSHGATEWAY_URL = "http://pushgateway.monitoring.svc.cluster.local:9091"

# Завантажуємо дані
X, y = load_iris(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

best_acc = 0
best_run = None

for lr in [0.01, 0.1, 1.0]:
    for epochs in [50, 100, 200]:
        with mlflow.start_run() as run:
            model = LogisticRegression(max_iter=epochs, C=lr)
            model.fit(X_train, y_train)

            preds = model.predict(X_test)
            acc = accuracy_score(y_test, preds)
            loss = log_loss(y_test, model.predict_proba(X_test))

            # Логування в MLflow
            mlflow.log_param("learning_rate", lr)
            mlflow.log_param("epochs", epochs)
            mlflow.log_metric("accuracy", acc)
            mlflow.log_metric("loss", loss)
            mlflow.sklearn.log_model(model, "model")

            # Відправка метрик у Prometheus PushGateway
            registry = prometheus_client.CollectorRegistry()
            acc_gauge = prometheus_client.Gauge("mlflow_accuracy", "Accuracy metric", ["run_id"], registry=registry)
            loss_gauge = prometheus_client.Gauge("mlflow_loss", "Loss metric", ["run_id"], registry=registry)
            acc_gauge.labels(run.info.run_id).set(acc)
            loss_gauge.labels(run.info.run_id).set(loss)

            prometheus_client.push_to_gateway(PUSHGATEWAY_URL, job="iris_training", registry=registry)

            # Зберігаємо найкращу модель
            if acc > best_acc:
                best_acc = acc
                best_run = run.info.run_id
                mlflow.artifacts.download_artifacts(run_id=best_run, artifact_path="model", dst_path="../best_model")

print(f"Найкращий run_id: {best_run} з accuracy={best_acc}")
