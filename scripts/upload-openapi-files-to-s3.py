from utils import (
    get_versions,
    set_urls_to_openapi_file,
    load_terraform_outputs,
    upload_openapi_schema,
    delete_all_openapi_schemas,
)
import json


def main():

    versions_metadata = get_versions()
    manifest = []
    urls = load_terraform_outputs()
    delete_all_openapi_schemas(urls["s3_bucket"])
    for version_metadata in versions_metadata:
        version = version_metadata["version"]
        openapi_path = version_metadata["openapi_path_swagger"]
        with open(openapi_path, "r") as f:
            openapi_schema = json.load(f)
        openapi_schema = set_urls_to_openapi_file(version, openapi_schema, urls)
        url = upload_openapi_schema(
            version, openapi_schema, urls["s3_bucket"], urls["aws_region"]
        )
        manifest.append({"url": url, "name": version})
    with open("src/api/doc/doc_manifest.json", "w") as f:
        json.dump(manifest, f, indent=2)


if __name__ == "__main__":
    main()
