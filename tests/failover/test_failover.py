import sys
import urllib.error
import urllib.request


def check_endpoint(name, url):
    print(f"Checking {name}")
    print(f"Endpoint: {url}")

    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            if response.status == 200:
                print(f"[HEALTHY] {name}")
                return True

    except (urllib.error.URLError, TimeoutError) as error:
        print(f"[UNHEALTHY] {name}: {error}")

    return False


def select_provider(aws_url, azure_url):
    print("\nMultiCloud Forge Failover Test")
    print("=" * 40)

    if check_endpoint("AWS", aws_url):
        print("\n[ACTIVE] AWS")
        return "aws"

    print("\nAWS unavailable. Attempting failover...\n")

    if check_endpoint("Azure", azure_url):
        print("\n[FAILOVER] Azure")
        return "azure"

    print("\n[CRITICAL] No healthy cloud provider available.")
    return None


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python test_failover.py "
            "<aws_health_url> <azure_health_url>"
        )
        sys.exit(1)

    provider = select_provider(
        sys.argv[1],
        sys.argv[2],
    )

    sys.exit(0 if provider else 1)