output "bucket_name" {
    value = aws_s3_bucket.this.bucket
}

output "bucket_domain_name" {
    value = aws_s3_bucket.this.bucket_domain_name
}
