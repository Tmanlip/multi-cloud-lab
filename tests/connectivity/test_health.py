import json
import sys
import urllib.error
import urllib.request


EXPECTED_FIELDS = {
    "status",
    "provider",
    "region",
    "environment",
    "timestamp",
    "version",
}


def check_endpoint(name, url, expected_provider):
    print(f"\nTesting {name}")
    print(f"Endpoint: {url}")

    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            status_code = response.status
            body = json.loads(response.read().decode("utf-8"))

    except urllib.error.URLError as error:
        print(f"[FAIL] Could not reach {name}: {error}")
        return False

    if status_code != 200:
        print(f"[FAIL] Expected HTTP 200, received {status_code}")
        return False

    missing_fields = EXPECTED_FIELDS - body.keys()

    if missing_fields:
        print(
            f"[FAIL] Missing fields: "
            f"{', '.join(sorted(missing_fields))}"
        )
        return False

    if body["status"] != "ok":
        print(
            f"[FAIL] Unexpected health status: "
            f"{body['status']}"
        )
        return False

    if body["provider"] != expected_provider:
        print(
            f"[FAIL] Expected provider '{expected_provider}', "
            f"received '{body['provider']}'"
        )
        return False

    print("[PASS] Endpoint healthy")
    print(f"Provider: {body['provider']}")
    print(f"Region: {body['region']}")
    print(f"Environment: {body['environment']}")
    print(f"Version: {body['version']}")

    return True


def main():
    if len(sys.argv) != 3:
        print(
            "Usage: python test_health.py "
            "<aws-health-url> <azure-health-url>"
        )
        sys.exit(2)

    aws_url = sys.argv[1]
    azure_url = sys.argv[2]

    results = [
        check_endpoint("AWS", aws_url, "aws"),
        check_endpoint("Azure", azure_url, "azure"),
    ]

    if all(results):
        print("\n[PASS] Multi-cloud health validation successful.")
        sys.exit(0)

    print("\n[FAIL] Multi-cloud health validation failed.")
    sys.exit(1)


if __name__ == "__main__":
    main()