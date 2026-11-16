# FastS3 (RustFS) S3 backend — endpoint and bucket are env-agnostic literals.
# Only credentials and the per-env state key are token-replaced.
#
# The remote backend is OPTIONAL: without it, Terraform keeps state locally
# in terraform.tfstate. It is nevertheless RECOMMENDED — remote state gives
# you shared/locked state, safe concurrent runs, and recovery if your
# machine or directory is lost.

bucket = "my-bucket-state"
key    = "lab.talos-bootstrap.tfstate"
region = "us-east-1"

endpoints = {
  s3 = "https://s3.mydomain.io"
}

access_key = "replaceme"
secret_key = "replaceme"

skip_credentials_validation = true
skip_metadata_api_check     = true
skip_region_validation      = true
skip_requesting_account_id  = true
use_path_style              = true

use_lockfile = true
