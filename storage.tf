# Uploads: recipe photos that users add.
resource "aws_s3_bucket" "uploads" {
  bucket = "${var.name}-uploads-${data.aws_caller_identity.current.account_id}"
}

# "So the app can show photos": anyone on the internet can read every object.
resource "aws_s3_bucket_policy" "uploads_public" {
  bucket = aws_s3_bucket.uploads.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicRead"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:*"
      Resource  = "${aws_s3_bucket.uploads.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
