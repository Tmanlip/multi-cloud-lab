import json
import os
from datetime import datetime, timezone


def lambda_handler(event, context):
    path = event.get("rawPath", "/")

    # Controlled failure endpoint for observability testing.
    if path == "/fail":
        raise RuntimeError("Intentional MultiCloud Forge observability test failure")

    if path not in ["/", "/health"]:
        return {
            "statusCode": 404,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "status": "not_found"
            })
        }

    response = {
        "status": "ok",
        "provider": "aws",
        "region": os.environ.get("AWS_REGION", "unknown"),
        "environment": os.environ.get("ENVIRONMENT", "unknown"),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "version": os.environ.get("APP_VERSION", "1.0.0"),
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(response)
    }