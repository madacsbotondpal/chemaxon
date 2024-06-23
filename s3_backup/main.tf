# Creating a bucket for backup storage
resource "aws_s3_bucket" "backup" {
  bucket = "backup-bucket-${var.environment}"

  tags = {
    Name          = "backup-bucket-${var.environment}"
    Created_by    = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

# Blocking all public access for the backup bucket
resource "aws_s3_bucket_public_access_block" "backup_public_access_block" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption, ensuring data security
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning to retain multiple versions of backups, which helps in case of any accident recovery
# With MFA delete enabled bucket versions can't be deleted without MFA
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Enabled"
  }
}

# Enable bucket lifecycle configuration to move bucket objects to the Glacier class after 30 days, which helps reducing cost
# And deletes objects after 180 days, ensuring compliance with backup retention policies
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_configuration" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "move-later-delete"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration {
      days = 180
    }
  }
}

# IAM policy to deny all access to the bucket, except the backup_loader role owners
data "aws_iam_policy_document" "backup_bucket_policy" {
  statement {
    sid    = "AllExceptUser"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.backup.arn,
      "${aws_s3_bucket.backup.arn}/*",
    ]

    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalARN"
      values = [
        "arn:aws:iam::123456789012:role/backup_uploader"
      ]
    }
  }
}

# Assign the above mentioned bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.backup.id
  policy = data.aws_iam_policy_document.backup_bucket_policy.json
}

# Create bucket for the backup bucket logs
resource "aws_s3_bucket" "logging" {
  bucket = "logging-bucket-${var.environment}"

  tags = {
    Name          = "logging-bucket-${var.environment}"
    Created_by    = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

# Bucket logging provides server access logging
# Server access logging provides detailed records for the requests that are made to a bucket.
resource "aws_s3_bucket_logging" "bucket_logging" {
  bucket = aws_s3_bucket.backup.id

  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "logs/"
}

# We make sure that the logs are versioned and cannot deleted without MFA for more security
resource "aws_s3_bucket_versioning" "bucket_log_versioning" {
  bucket = aws_s3_bucket.logging.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Enabled"
  }
}

# Blocking all public access for the log bucket
resource "aws_s3_bucket_public_access_block" "backup_log_public_access_block" {
  bucket = aws_s3_bucket.logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# We also move the logging buckets data to the Glacier class storage and delete after 180 days
resource "aws_s3_bucket_lifecycle_configuration" "bucket_log_lifecycle_configuration" {
  bucket = aws_s3_bucket.logging.id

  rule {
    id     = "move-later-delete"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration {
      days = 180
    }
  }
}