import webbrowser
import argparse
import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import CONFIG


def get_account_id(stage):
    """
    Gets the AWS account ID for the given stage from pyproject.toml
    """
    try:
        account_id = CONFIG["aws_accounts"][stage]["aws_account"]

        region = CONFIG["aws_region"]

        return account_id, region
    except (KeyError, FileNotFoundError) as e:
        print(f"Error: {e}")
        print(f"Stage '{stage}' not found in pyproject.toml or file is missing")
        return None, None


def get_service_url(service, region, account_id):
    """
    Returns the URL for the specified AWS service using format:
    https://{account_id}-{hash}.{region}.console.aws.amazon.com/{service}/home?region={region}#/{endpoint}
    """
    # Account specific hash - this is part of AWS console URLs
    account_hash = "2gu4thj2"  # Hash fixed for account 408566731358

    service_endpoints = {
        "lambda": "functions",
        "apigateway": "apis",
        "s3": "buckets",
        "acm": "",
        "cloudfront": "distributions",
        "cognito": "user-pools",
        "iam": "home",
    }

    endpoint = service_endpoints.get(service.lower(), "")

    # Using the format from the example URL with correct dash between account_id and hash
    return f"https://{account_id}-{account_hash}.{region}.console.aws.amazon.com/{service}/home?region={region}#/{endpoint}"


def open_aws_service(stage, service):
    """
    Opens the specified AWS service console for the given stage in the default browser.
    """
    account_id, region = get_account_id(stage)

    if account_id and region:
        service_url = get_service_url(service, region, account_id)

        # Ajouter recherche avec STAGE et APP_NAME depuis les variables d'environnement
        search_query = ""
        if "STAGE" in os.environ and "APP_NAME" in os.environ:
            search_query = f"{os.environ['STAGE']}-{os.environ['APP_NAME']}"
            # Format correct pour la recherche dans AWS Console
            service_url = f"{service_url}?fo=and&o0=%3A&v0={search_query}"

        if service_url:
            webbrowser.open(service_url)
        else:
            print(f"Service '{service}' is not supported")
    else:
        print("Failed to open AWS console")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Open AWS service console for a specific stage"
    )
    parser.add_argument(
        "stage", choices=["dev", "prod"], help="Stage environment (dev or prod)"
    )
    parser.add_argument(
        "service",
        help="AWS service to open (lambda, apigateway, s3, acm, cloudfront, etc.)",
    )
    args = parser.parse_args()

    open_aws_service(args.stage, args.service)
