import os
import mlflow
import mlflow.sklearn
import prometheus_client
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, log_loss


MLFLOW_URI = os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5001")
mlflow.set_tracking_uri(MLFLOW_URI)
mlflow.set_experiment("iris-experiment")
os.environ["AWS_ACCESS_KEY_ID"] = "minio"
os.environ["AWS_SECRET_ACCESS_KEY"] = "minio123"
os.environ["MLFLOW_S3_ENDPOINT_URL"] = "http://localhost:9000"
os.environ["MLFLOW_ARTIFACT_ROOT"] = "s3://mlflow-artifacts"

PUSHGATEWAY_URL = "http://localhost:9091"


X, y = load_iris(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

best_acc = 0
best_run = None


for lr in [0.01, 0.1, 1.0]:
    for epochs in [50, 100, 200]:
        print(f"Training model with lr={lr}, epochs={epochs}")
        with mlflow.start_run() as run:
            # Train model
            model = LogisticRegression(max_iter=epochs, C=lr)
            model.fit(X_train, y_train)

            # Predict and evaluate
            preds = model.predict(X_test)
            acc = accuracy_score(y_test, preds)
            loss = log_loss(y_test, model.predict_proba(X_test))

            # Log params and metrics to MLflow
            mlflow.log_param("learning_rate", lr)
            mlflow.log_param("epochs", epochs)
            mlflow.log_metric("accuracy", acc)
            mlflow.log_metric("loss", loss)

            # Log model to MLflow
            try:
                mlflow.sklearn.log_model(model, "model")
            except Exception as e:
                print(f"Failed to log model: {e}")

            print(f"MLflow run {run.info.run_id} | acc={acc:.4f}, loss={loss:.4f}")

            # Push metrics to Prometheus
            registry = prometheus_client.CollectorRegistry()
            acc_gauge = prometheus_client.Gauge(
                "mlflow_accuracy", "Accuracy metric", ["run_id"], registry=registry
            )
            loss_gauge = prometheus_client.Gauge(
                "mlflow_loss", "Loss metric", ["run_id"], registry=registry
            )
            acc_gauge.labels(run.info.run_id).set(acc)
            loss_gauge.labels(run.info.run_id).set(loss)

            try:
                prometheus_client.push_to_gateway(
                    PUSHGATEWAY_URL, job="iris_training", registry=registry
                )
                print("Metrics pushed to Prometheus PushGateway")
            except Exception as e:
                print(f"Failed to push metrics: {e}")

            # Track best model
            if acc > best_acc:
                best_acc = acc
                best_run = run.info.run_id
                try:
                    mlflow.artifacts.download_artifacts(
                        run_id=best_run, artifact_path="model", dst_path="./best_model"
                    )
                    print(f"Downloaded best model artifacts to ./best_model")
                except Exception as e:
                    print(f"Failed to download artifacts: {e}")

print(f"Best run: {best_run} with accuracy={best_acc:.4f}")
