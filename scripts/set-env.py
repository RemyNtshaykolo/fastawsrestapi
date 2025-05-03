import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import CONFIG
from src.utils import get_versions_list
import toml
import json
from pathlib import Path


def get_app_name():
    with open("pyproject.toml", "r") as file:
        pyproject_data = toml.load(file)
    app_name = pyproject_data["project"]["name"]

    return app_name


def main(stage):

    tfvars_json = f".infra/terraform/{stage}.tfvars.json"
    if stage not in CONFIG["aws_accounts"]:
        declared_stages = ", ".join(CONFIG["aws_accounts"].keys())
        print(
            f"Stage '{stage}' does not exist in config.py, available stages: {declared_stages}"
        )
        sys.exit(1)

    aws_account = CONFIG["aws_accounts"][stage]
    aws_profile = aws_account["profile"]
    aws_account_id = aws_account["aws_account"]
    aws_region = CONFIG["aws_region"]
    domain_name = CONFIG["networking"]["domain_name"]
    use_custom_domain = CONFIG["networking"]["use_custom_domain"]
    oauth2_clients = CONFIG["authentication"]["oauth2_clients"]
    usage_plans = CONFIG["authentication"]["usage_plans"]
    app_name = get_app_name()
    api_title = CONFIG["documentation"]["title"]
    api_versions = get_versions_list()

    env_file = Path(f".env.{stage}")

    # Variables defined by the script
    env_vars = {
        "AWS_PROFILE": aws_profile,
        "AWS_ACCOUNT_ID": aws_account_id,
        "AWS_REGION": aws_region,
        "DOMAIN_NAME": domain_name,
        "USE_CUSTOM_DOMAIN": "true" if use_custom_domain else "false",
        "APP_NAME": app_name,
        "TF_WORKSPACE": stage,
        "PYTHONPATH": f"src",
        "API_TITLE": api_title,
    }

    # Export to Python process environment
    for key, value in env_vars.items():
        os.environ[key] = value

    # Load existing .env.<stage> content, if it exists
    existing_vars = {}
    if env_file.exists():
        with env_file.open("r") as f:
            for line in f:
                if line.strip() and not line.startswith("#"):
                    k, v = line.strip().split("=", 1)
                    existing_vars[k] = v

    # Update only the variables defined by this script
    existing_vars.update(env_vars)

    # Write the merged variables back to the file
    with env_file.open("w") as f:
        for k, v in existing_vars.items():
            f.write(f'{k}="{v}"\n')

    # TF_VARS.json
    final_json = {
        "aws_account_id": aws_account_id,
        "aws_region": aws_region,
        "app_name": app_name,
        "stage": stage,
        "aws_profile": aws_profile,
        "domain_name": domain_name,
        "oauth2_clients": oauth2_clients,
        "usage_plans": usage_plans,
        "api_versions": api_versions,
        "use_custom_domain": use_custom_domain,
    }

    with open(tfvars_json, "w") as f:
        json.dump(final_json, f, indent=2)


if __name__ == "__main__":
    stage = sys.argv[1]
    main(stage)
