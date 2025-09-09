# simple logging stub for metrics
def lambda_handler(event, context):
    print("Logging metrics...")
    # Виводимо те, що отримали від попереднього кроку
    print("Received event:", event)
    # Імітуємо логування метрик (наприклад, в CloudWatch або зовнішній сервіс)
    metrics = {
        "validation_status": event.get("status", "unknown"),
        "extra": event
    }
    print("Metrics:", metrics)
    return {"logged": True, "metrics": metrics}
