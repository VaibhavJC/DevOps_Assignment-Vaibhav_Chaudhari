resource "aws_s3_bucket" "log_bucket" {
    bucket = var.bucket_name

    tags = {
        Name = "nimbuskart-app-logs-bucket-26"
    }
  
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
    bucket = aws_s3_bucket.log_bucket.id
    versioning_configuration {
        status = "Enabled"
    }

    depends_on = [aws_s3_bucket.log_bucket]
}

resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
    bucket = aws_s3_bucket.log_bucket.id
    rule {
        id = "expire-noncurrent-versions"
        status = "Enabled"

        expiration {
            days = 30
        }
    }

    depends_on = [aws_s3_bucket.log_bucket]
}