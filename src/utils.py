import os
import inspect
import json
import boto3


def get_current_version():
    """
    Get the current version of the api when executed in the app.py files of each version.
    """
    frame = inspect.stack()[1]  # Récupère l'appelant direct
    caller_file = frame.filename  # Chemin du fichier appelant
    folder = os.path.basename(os.path.dirname(os.path.abspath(caller_file)))
    return folder


def get_versions():
    """
    Get the list of versions and their metadata of the api from the `src/api/versions`.
    """
    versions_path = "./src/api/versions"
    versions = [
        d
        for d in os.listdir(versions_path)
        if os.path.isdir(os.path.join(versions_path, d)) and d != "__pycache__"
    ]
    versions.sort()
    return [
        {
            "version": d,
            "path": os.path.join(versions_path, d),
            "openapi_path_terraform": os.path.join(
                versions_path, d, f"openapi-{d}-terraform.json"
            ),
            "openapi_path_swagger": os.path.join(
                versions_path, d, f"openapi-{d}-swagger.json"
            ),
        }
        for d in versions
    ]


def get_versions_list():
    """
    Get the list of versions of the api from the `src/api/versions` folder.
    """
    versions = get_versions()
    return [v["version"] for v in versions]


def set_servers_in_openapi_file(version, openapi_schema, urls):
    """
    Set the urls of the api in the openapi schema.
    """
    api_urls = urls["api_urls"]
    if version not in api_urls:
        raise ValueError(f"Version {version} not found in urls")

    if os.environ["USE_CUSTOM_DOMAIN"] == "true":
        openapi_schema["servers"] = [{"url": api_urls[version]["custom"]}]
    else:
        openapi_schema["servers"] = [{"url": api_urls[version]["raw"]}]
    return openapi_schema


def upload_openapi_schema(version, openapi_schema, bucket, aws_region):
    """
    Upload the openapi schema to the s3 bucket.
    """
    s3_key = f"openapi-{version}.json"
    s3 = boto3.client("s3")
    url = f"http://{bucket}.s3.{aws_region}.amazonaws.com/{s3_key}"
    try:
        s3.put_object(Bucket=bucket, Key=s3_key, Body=json.dumps(openapi_schema))
        print(f"Openapi schema uploaded to {url}")
        return url
    except Exception as e:
        print(f"Error uploading file to S3: {str(e)}")
        raise e


def delete_all_openapi_schemas(bucket):
    """
    Delete all the openapi schemas from the s3 bucket.
    """
    s3 = boto3.client("s3")
    response = s3.list_objects_v2(Bucket=bucket, Prefix="openapi-")
    if "Contents" in response:
        for obj in response["Contents"]:
            s3.delete_object(Bucket=bucket, Key=obj["Key"])
    


def load_terraform_outputs():
    with open(f".infra/terraform/{os.environ['STAGE']}-outputs.json", "r") as f:
        outputs = json.load(f)
        return {
            "api_urls": outputs["api_gateway_urls"]["value"],
            "cognito_url": outputs["cognito_user_pool_domain_url"]["value"],
            "s3_bucket": outputs["api_documentation_bucket_name"]["value"],
            "aws_region": outputs["aws_region"]["value"],
        }


if __name__ == "__main__":
    print(get_versions_list())
