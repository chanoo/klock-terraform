resource "aws_s3_bucket" "${var.project_name}" {
  bucket = var.s3_bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "${var.project_name}" {
  bucket = aws_s3_bucket.${var.project_name}.id

  block_public_acls   = true
  block_public_policy = true
}
