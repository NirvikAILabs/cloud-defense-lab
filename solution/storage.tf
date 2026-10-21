# Uploads: private. The app hands out short-lived signed URLs for photos
# (or serves them through a CDN with origin access control).
resource "aws_s3_bucket" "uploads" {
  bucket = "${var.name}-uploads-${data.aws_caller_identity.current.account_id}"
}

# Lab: storage. Block every kind of public access.
resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lab: storage. Keep earlier versions, so deleted or overwritten files can be recovered.
resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lab: storage. Only HTTPS, and nobody may encrypt objects with their own key
# (SSE-C), which ransomware has abused to lock owners out of their data.
resource "aws_s3_bucket_policy" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "HttpsOnly"
        Effect    = "Deny"
        Principal = { AWS = "*" }
        Action    = "s3:*"
        Resource  = "${aws_s3_bucket.uploads.arn}/*"
        Condition = { Bool = { "aws:SecureTransport" = "false" } }
      },
      {
        Sid       = "NoCustomerProvidedKeys"
        Effect    = "Deny"
        Principal = { AWS = "*" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.uploads.arn}/*"
        Condition = { Null = { "s3:x-amz-server-side-encryption-customer-algorithm" = "false" } }
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.uploads]
}
