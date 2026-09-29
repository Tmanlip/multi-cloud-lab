import json
import os
from datetime import datetime, timezone

import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@app.route(route="health", methods=["GET"])
def health(req: func.HttpRequest) -> func.HttpResponse:
    response = {
        "status": "ok",
        "provider": "azure",
        "region": os.environ.get("REGION", "unknown"),
        "environment": os.environ.get("ENVIRONMENT", "unknown"),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "version": os.environ.get("APP_VERSION", "1.0.0"),
    }

    return func.HttpResponse(
        json.dumps(response),
        status_code=200,
        mimetype="application/json",
    )
    
@app.route(route="fail", methods=["GET"])
def fail(req: func.HttpRequest) -> func.HttpResponse:
    response = {
        "status": "error",
        "provider": "azure",
        "environment": os.environ.get("ENVIRONMENT", "unknown"),
        "message": "Intentional MultiCloud Forge observability test failure",
    }

    return func.HttpResponse(
        json.dumps(response),
        status_code=500,
        mimetype="application/json",
    )