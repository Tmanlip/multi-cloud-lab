import json
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TERRAFORM_DIR = ROOT / "terraform" / "environments" / "dev"


def run_terraform(*args):
    result = subprocess.run(
        ["terraform", *args],
        cwd=TERRAFORM_DIR,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr)
        sys.exit(result.returncode)

    return result.stdout


def pass_test(message):
    print(f"[PASS] {message}")


def fail_test(message):
    print(f"[FAIL] {message}")
    sys.exit(1)


print("MultiCloud Forge Infrastructure Test")
print("=" * 45)


# --------------------------------------------------
# Terraform Validate
# --------------------------------------------------

print("\nTesting Terraform configuration...")

run_terraform("validate")

pass_test("Terraform configuration is valid")


# --------------------------------------------------
# Terraform State
# --------------------------------------------------

print("\nReading Terraform state...")

state_raw = run_terraform("show", "-json")
state = json.loads(state_raw)

root_module = state.get("values", {}).get("root_module", {})


def collect_resources(module):
    resources = []

    resources.extend(module.get("resources", []))

    for child in module.get("child_modules", []):
        resources.extend(collect_resources(child))

    return resources


resources = collect_resources(root_module)

resource_types = {resource["type"] for resource in resources}


# --------------------------------------------------
# Required AWS Resources
# --------------------------------------------------

print("\nChecking AWS infrastructure...")

required_aws = {
    "aws_vpc",
    "aws_subnet",
    "aws_internet_gateway",
    "aws_route_table",
    "aws_security_group",
    "aws_lambda_function",
    "aws_lambda_function_url",
    "aws_cloudwatch_log_group",
    "aws_cloudwatch_metric_alarm",
}

for resource_type in required_aws:
    if resource_type not in resource_types:
        fail_test(f"Missing AWS resource: {resource_type}")

    pass_test(resource_type)


# --------------------------------------------------
# Required Azure Resources
# --------------------------------------------------

print("\nChecking Azure infrastructure...")

required_azure = {
    "azurerm_resource_group",
    "azurerm_virtual_network",
    "azurerm_subnet",
    "azurerm_network_security_group",
    "azurerm_storage_account",
    "azurerm_service_plan",
    "azurerm_linux_function_app",
    "azurerm_application_insights",
    "azurerm_monitor_scheduled_query_rules_alert_v2",
}

for resource_type in required_azure:
    if resource_type not in resource_types:
        fail_test(f"Missing Azure resource: {resource_type}")

    pass_test(resource_type)


# --------------------------------------------------
# Terraform Outputs
# --------------------------------------------------

print("\nChecking Terraform outputs...")

outputs = state.get("values", {}).get("outputs", {})

required_outputs = {
    "aws_health_url",
    "azure_health_url",
}

for output in required_outputs:
    if output not in outputs:
        fail_test(f"Missing Terraform output: {output}")

    value = outputs[output].get("value")

    if not value:
        fail_test(f"Terraform output is empty: {output}")

    pass_test(f"{output} configured")


# --------------------------------------------------
# Summary
# --------------------------------------------------

print("\n" + "=" * 45)
print("[PASS] Multi-cloud infrastructure validation successful.")