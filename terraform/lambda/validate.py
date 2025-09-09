# simple data validation stub for MLOps pipeline
def lambda_handler(event, context):
    print("Validating data...")
    # Приклад простого логічного рішення: перевіряємо чи є поле 'data' в input
    if not isinstance(event, dict):
        print("Invalid event type, expected JSON object")
        return {"status": "failed", "reason": "invalid_event_type"}

    if "data" not in event:
        print("No 'data' in input. Failing validation.")
        return {"status": "failed", "reason": "no_data"}

    # Умовна валідація
    data = event["data"]
    if not data:
        print("Empty data")
        return {"status": "failed", "reason": "empty_data"}

    print("Validation succeeded")
    # Повертаємо вихід, який може використовуватися в наступному кроці
    return {"status": "ok", "validated_records": len(data) if hasattr(data, "__len__") else 1}
