resource "aws_s3_bucket" "bucket" {
  bucket = "klock-bucket"
  acl    = "private"

  tags = {
    Name        = "Klock bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "klock-bucket"
  key    = "chat-bot-profile-image/"
  acl    = "private"
  content = ""
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}
