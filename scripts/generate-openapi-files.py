import os
from utils import get_versions
import importlib.util
import json
from fastapi.openapi.utils import get_openapi
from pydantic import BaseModel
from typing import Optional


class Throttling(BaseModel):
    rateLimit: float
    burstLimit: int

    class Config:
        extra = "forbid"  # ⛔ reject unknown keys


class ApiCache(BaseModel):
    enabled: bool
    size: float

    class Config:
        extra = "forbid"  # ⛔ reject unknown keys


class CacheKeys(BaseModel):
    headers: Optional[list[str]] = None
    query: Optional[list[str]] = None

    class Config:
        extra = "forbid"  # ⛔ reject unknown keys


class RouteCache(BaseModel):
    maxTtl: int
    enabled: bool
    keys: CacheKeys

    class Config:
        extra = "forbid"  # ⛔ reject unknown keys


def format_pydantic_errors(e: Exception) -> str:
    """
    Format Pydantic ValidationError into a readable string.
    """
    try:
        return "\n" + "\n".join(
            f"❌ {'.'.join(map(str, err['loc']))}: {err['msg']} ({err['type']})"
            for err in e.errors()
        )
    except Exception:
        return str(e)


OPTION_METHOD = {
    "options": {
        "summary": "CORS support",
        "description": "Enable CORS by returning correct headers",
        "tags": ["CORS"],
        "responses": {
            "200": {
                "description": "Default response for CORS method",
                "headers": {
                    "Access-Control-Allow-Headers": {"schema": {"type": "string"}},
                    "Access-Control-Allow-Methods": {"schema": {"type": "string"}},
                    "Access-Control-Allow-Origin": {"schema": {"type": "string"}},
                    "Access-Control-Allow-Credentials": {"schema": {"type": "boolean"}},
                },
                "content": {"application/json": {}},
            }
        },
        "x-amazon-apigateway-integration": {
            "responses": {
                "default": {
                    "statusCode": "200",
                    "responseParameters": {
                        "method.response.header.Access-Control-Allow-Headers": "'*'",
                        "method.response.header.Access-Control-Allow-Methods": "'*'",
                        "method.response.header.Access-Control-Allow-Origin": "'*'",
                        "method.response.header.Access-Control-Allow-Credentials": "'true'",
                    },
                }
            },
            "requestTemplates": {"application/json": '{"statusCode": 200}'},
            "passthroughBehavior": "never",
            "type": "MOCK",
        },
    }
}


def generate_openapi_files(app, version_metadata: dict = None):
    """
    Generates two OpenAPI files:
    - `swagger.json`: contains only normally exposed routes
    - `terraform.json`: forces all routes to appear, even those with include_in_schema=False
    """
    openapi_file_swagger = version_metadata["openapi_path_swagger"]
    openapi_file_terraform = version_metadata["openapi_path_terraform"]

    print("📦 Generating Swagger schema (visible routes only)")
    schema_swagger = get_openapi(
        title=app.title,
        version=app.version,
        openapi_version=app.openapi_version,
        description=app.description,
        routes=app.routes,
        servers=app.servers,
    )

    with open(openapi_file_swagger, "w") as f:
        json.dump(schema_swagger, f, indent=2)
        print(f"✅ Swagger schema saved to {openapi_file_swagger}")

    print("📦 Generating Terraform schema (all routes, including hidden ones)")

    # 🔄 Temporary save & override
    original_include = {route.path: route.include_in_schema for route in app.routes}
    for route in app.routes:
        route.include_in_schema = True

    schema_terraform = get_openapi(
        title=app.title,
        version=app.version,
        openapi_version=app.openapi_version,
        description=app.description,
        routes=app.routes,
        servers=app.servers,
    )

    if "cache_configuration" in app.extra:
        try:
            ApiCache.model_validate(app.extra["cache_configuration"])
            schema_terraform["x-cache"] = app.extra["cache_configuration"]
        except Exception as e:
            print(
                f"\033[91mError: Check your cache configuration in src/api/versions/{version_metadata['version']}/app.py file. {format_pydantic_errors(e)} \033[0m"
            )
            exit(1)

    security_schemes = schema_terraform.get("components", {}).get("securitySchemes", {})

    if "Oauth2ClientCredentials" in security_schemes:
        schema_terraform["components"]["securitySchemes"][
            "Oauth2ClientCredentials"
        ].update(
            {
                "in": "header",
                "name": "Authorization",
                "type": "apiKey",
                "x-amazon-apigateway-authtype": "cognito_user_pools",
                "x-amazon-apigateway-authorizer": {
                    "type": "cognito_user_pools",
                    "providerARNs": ["${cognito_user_pool_arn}"],
                },
            }
        )

    # For each response in each route, inject CORS headers
    for path in schema_terraform["paths"]:
        for method in schema_terraform["paths"][path]:
            if "x-conf" in schema_terraform["paths"][path][method]:
                x_conf = schema_terraform["paths"][path][method]["x-conf"]
                if "throttling" in x_conf:
                    try:
                        Throttling.model_validate(x_conf["throttling"])
                        schema_terraform["paths"][path][method]["x-throttling"] = (
                            x_conf["throttling"]
                        )
                    except Exception as e:
                        print(
                            f"\033[91mError: Check your throttling configuration in src/api/versions/{version_metadata['version']} folder for the {path} route. {format_pydantic_errors(e)} \033[0m"
                        )
                        exit(1)
            if "caching" in x_conf:
                try:
                    schema_terraform["paths"][path][method]["x-cache"] = x_conf[
                        "caching"
                    ]
                except Exception as e:
                    print(
                        f"\033[91mError: Check your caching configuration in src/api/versions/{version_metadata['version']} folder for the {path} route. {format_pydantic_errors(e)} \033[0m"
                    )
                    exit(1)

            for status_code in schema_terraform["paths"][path][method]["responses"]:
                response_block = schema_terraform["paths"][path][method]["responses"][
                    status_code
                ]

                # Ensure "headers" field exists
                response_block.setdefault("headers", {})

                # Inject CORS headers
                response_block["headers"].update(
                    {
                        "Access-Control-Allow-Headers": {"schema": {"type": "string"}},
                        "Access-Control-Allow-Methods": {"schema": {"type": "string"}},
                        "Access-Control-Allow-Origin": {"schema": {"type": "string"}},
                    }
                )

            if "security" in schema_terraform["paths"][path][method]:
                # Check if OAuth2 security exists
                has_oauth2 = False
                for security_item in schema_terraform["paths"][path][method][
                    "security"
                ]:
                    if "Oauth2ClientCredentials" in security_item:
                        has_oauth2 = True
                        break

                if has_oauth2:
                    scope = f"{method.upper()}.{path.lstrip('/').replace('/', '.')}"
                    schema_terraform["paths"][path][method]["security"] = [
                        {"Oauth2ClientCredentials": [scope]}
                    ]

            schema_terraform["paths"][path][method][
                "x-amazon-apigateway-integration"
            ] = {
                "type": "AWS_PROXY",
                "httpMethod": "POST",
                "uri": "${shared_lambda_arn}",
                "passthroughBehavior": "when_no_match",
            }

            if "x-conf" in schema_terraform["paths"][path][method]:
                x_conf = schema_terraform["paths"][path][method]["x-conf"]
                if "caching" in x_conf and "keys" in x_conf["caching"]:
                    keys = x_conf["caching"]["keys"]
                    cache_key_parameters = []

                    for header in keys.get("headers", []):
                        cache_key_parameters.append(f"method.request.header.{header}")

                    for query_param in keys.get("query", []):
                        cache_key_parameters.append(
                            f"method.request.querystring.{query_param}"
                        )

                    schema_terraform["paths"][path][method][
                        "x-amazon-apigateway-integration"
                    ]["cacheKeyParameters"] = cache_key_parameters

    # Add CORS support to all routes
    for route in schema_terraform["paths"]:
        schema_terraform["paths"][route] = {
            **schema_terraform["paths"][route],
            **OPTION_METHOD,
        }

    with open(openapi_file_terraform, "w") as f:
        json.dump(schema_terraform, f, indent=2)
        print(f"✅ Terraform schema saved to {openapi_file_terraform}")

    # 🔙 Restoration
    for route in app.routes:
        route.include_in_schema = original_include[route.path]

    print("🎉 OpenAPI files generated successfully.")


def import_app_from_path(version):
    version_path = os.path.join("./src/api/versions", version)
    app_path = os.path.join(version_path, "app.py")
    spec = importlib.util.spec_from_file_location("app", app_path)
    app = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(app)
    return app


def main():
    versions_metadata = get_versions()
    for version_metadata in versions_metadata:
        app = import_app_from_path(version_metadata["version"]).app
        generate_openapi_files(app, version_metadata)


if __name__ == "__main__":
    main()
