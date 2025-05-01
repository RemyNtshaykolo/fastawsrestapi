#!/bin/bash
bucket_name=$(jq -r .api_documentation_bucket_name.value .infra/terraform/$STAGE-outputs.json)

echo "📦 Pushing swagger-ui documentation to s3://${bucket_name}/swagger-ui"

aws s3 sync .swagger-ui s3://${bucket_name}
aws s3 cp src/api/doc/icon.png s3://${bucket_name}/icon.png

# Retrieve aws region in pyproject.toml
aws_region=$(uvx --from=toml-cli toml get --toml-path=pyproject.toml tool.infrastructure.aws_region)

echo "✨ Documentation successfully published!"

# Make the documentation URL message stand out with ASCII art and colors
echo
echo -e "\033[1;35m"  # Magenta bold text
echo "╔═════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                         ║"
echo "║                   📚 DOCUMENTATION PUBLISHED! 📚                        ║"
echo "║                                                                         ║"
echo "╚═════════════════════════════════════════════════════════════════════════╝"
echo -e "\033[1;36m"  # Cyan bold text
echo "   🌐 ACCESS YOUR DOCUMENTATION AT:"
echo 
echo "   📘 http://${bucket_name}.s3-website.${aws_region}.amazonaws.com"
echo 
echo -e "\033[0m"  # Reset text formatting

