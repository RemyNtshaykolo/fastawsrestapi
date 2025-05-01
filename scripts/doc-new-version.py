import os
import sys

sys.path.append("src")
import shutil
from utils import get_versions
import re
import glob


def main():
    try:
        versions_metadata = get_versions()
        versions = [v["version"] for v in versions_metadata]

        # Regex to extract the version number
        version_regex = r"v(\d+)"

        # Extract the version numbers and convert to integers
        version_numbers = []
        for v in versions:
            match = re.search(version_regex, v)
            if not match:
                raise ValueError(f"Invalid version format: {v}")
            version_numbers.append(int(match.group(1)))

        if len(version_numbers) == 0:
            new_version = 1
        else:
            new_version = int(version_numbers[-1]) + 1

        # Add confirmation message
        print(f"Creating version {new_version}...")

        # Show existing versions and ask for template choice
        if version_numbers:
            print("\nExisting versions:")
            for num in version_numbers:
                print(f"- Version {num}")

            while True:
                choice = input(
                    "\nWould you like to use an existing version as template? (y/n): "
                ).lower()
                if choice in ["y", "n"]:
                    break
                print("Please answer 'y' or 'n'")

            if choice == "y":
                while True:
                    template_version = input(
                        f"Enter just the number (between {min(version_numbers)} and {max(version_numbers)}) of the version to use as template: "
                    )
                    try:
                        template_version = int(template_version)
                        if template_version in version_numbers:
                            break
                        print(
                            f"Version {template_version} does not exist. Please enter one of these numbers: {', '.join(map(str, version_numbers))}"
                        )
                    except ValueError:
                        print("Please enter only the number (for example: 2)")

                template_path = f"src/api/versions/v{template_version}"
                print(f"Using version {template_version} as template...")
            else:
                template_path = "src/api/template"
                print("Using default template...")
        else:
            template_path = "src/api/template"
            print("No existing versions found. Using default template...")

        # Create new version directory
        version_path = f"src/api/versions/v{new_version}"
        try:
            os.makedirs(version_path, exist_ok=True)
        except OSError as e:
            raise OSError(f"Failed to create directory {version_path}: {str(e)}")

        # Copy template to new version
        try:
            shutil.copytree(template_path, version_path, dirs_exist_ok=True)

            # Delete all openapi files from the template version
            openapi_files = glob.glob(f"{version_path}/openapi-*")
            for file in openapi_files:
                os.remove(file)
                print(f"Removed file: {file}")

        except (shutil.Error, OSError) as e:
            raise OSError(f"Failed to copy template to {version_path}: {str(e)}")

        print(f"Version {new_version} created successfully!")

    except Exception as e:
        print(f"Error: {str(e)}")
        exit(1)


if __name__ == "__main__":
    main()
