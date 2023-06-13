terraform {
    required_version = ">= 1.0.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = ">= 4.0.0"
        }
    }
}

data "aws_canonical_user_id" "this" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "this" {}

resource "aws_s3_bucket" "this" {
    bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "this" {
    bucket = aws_s3_bucket.this.id
    rule {
        object_ownership = "ObjectWriter"
    }
}

resource "aws_s3_bucket_acl" "this" {
    bucket = aws_s3_bucket.this.id
    access_control_policy {
        grant {
            grantee {
                id = data.aws_canonical_user_id.this.id
                type = "CanonicalUser"
            }
            permission = "FULL_CONTROL"
        }
        grant {
            grantee {
                type = "CanonicalUser"
                id = data.aws_cloudfront_log_delivery_canonical_user_id.this.id
            }
            permission = "FULL_CONTROL"

        }
        owner {
            id = data.aws_canonical_user_id.this.id
        }
    }

    # This `depends_on` is to prevent "AccessControlListNotSupported: The bucket does not allow ACLs."
    depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
    bucket = aws_s3_bucket.this.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    bucket = aws_s3_bucket.this.bucket
    rule {
        bucket_key_enabled = var.kms_arn != null
        dynamic apply_server_side_encryption_by_default {
            for_each = var.kms_arn == null ? [true] : []
            content {
                sse_algorithm = "AES256"
            }
        }
        dynamic apply_server_side_encryption_by_default {
            for_each = var.kms_arn == null ? [] : [true]
            content {
                kms_master_key_id = var.kms_arn
                sse_algorithm = "aws:kms"
            }
        }
    }
}

resource "aws_s3_bucket_versioning" "this" {
    count = var.versioning ? 1 : 0
    bucket = aws_s3_bucket.this.bucket
    versioning_configuration {
        status = "Enabled"
    }
}
