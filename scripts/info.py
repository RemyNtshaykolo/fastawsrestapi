#!/usr/bin/env python3
import json
import os
import sys
from pathlib import Path
import argparse
from rich.console import Console
from rich.table import Table


def main():
    parser = argparse.ArgumentParser(
        description="Display links from STAGE-output.json file"
    )
    parser.add_argument(
        "stage", nargs="?", default="dev", help="Stage name (default: dev)"
    )
    args = parser.parse_args()

    stage = args.stage
    output_file = Path(f".infra/terraform/{stage}-outputs.json")

    if not output_file.exists():
        print(f"Error: {output_file} file not found.")
        return 1

    try:
        with open(output_file, "r") as f:
            outputs = json.load(f)

        console = Console()

        table = Table(title=f"Links for {stage.upper()} Environment")
        table.add_column("Service", style="cyan")
        table.add_column("URL", style="green")

        # API Gateway URLs
        if "api_gateway_urls" in outputs:
            api_urls = outputs["api_gateway_urls"]["value"]
            for version, url in api_urls.items():
                table.add_row(f"API Gateway ({version})", url)

        # Cognito URL
        if "cognito_user_pool_domain_url" in outputs:
            cognito_url = outputs["cognito_user_pool_domain_url"]["value"]
            table.add_row("Cognito User Pool", cognito_url)

        # API Documentation URL
        if "api_documentation_url" in outputs:
            doc_url = outputs["api_documentation_url"]["value"]
            table.add_row("API Documentation", doc_url)

        # Website URL
        if "website_url" in outputs:
            website_url = outputs["website_url"]["value"]
            table.add_row("Website", website_url)

        console.print(table)

    except json.JSONDecodeError:
        raise Exception(f"Error: Invalid JSON in {output_file}")
    except Exception as e:
        raise Exception(f"Error: {str(e)}")


if __name__ == "__main__":
    main()
