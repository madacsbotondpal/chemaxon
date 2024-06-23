# Task

We have an application that stores data on a filesystem, and our backup policy requires that it stores backups for 180 days and no more. You have selected S3 as the backup storage in a different account.

Your goal is to ensure these backups are stored according to best practices. Please implement an S3 bucket with the appropriate configuration you think of as best practices for this task. Recommended ways to approach the problem are security, cost considerations. 

Actually uploading the files as a cron job or something is not part of this exercise, but you have to ensure that the following IAM role is able to upload files into the bucket arn:aws:iam::123456789012:role/backup_uploader.

# S3 Bucket configuration 

This directory contains the partial configuration of an S3 bucket, which is used to store backup files for 180 days and a log bucket, which stores the backup buckets access logs.
I create different terraform resources to make sure that our backup is safe, reduntant and cost effective. 
-  `aws_s3_bucket_public_access_block` - lets you block all public access
-  `aws_s3_bucket_server_side_encryption_configuration` - encypts all objects in the bucket
-  `aws_s3_bucket_versioning` - lets you retain multiple versions of the backup in case of accidental deletion or overwrites
-  `aws_s3_bucket_lifecycle_configuration` - moves old objects to a cheaper bucket type (GLACIER) to reduce cost and deletes objects after 180 days of lifetime, ensuring compliance with backup retention policies
-  `aws_s3_bucket_policy` with `aws_iam_policy_document` - make sure that only the right role can access the bucket and its resources
-  `aws_s3_bucket_logging` with a log bucket - make sure that we can log all server accesses 

We ensure resource security by disallowing public access, server-side encryption and restricting access. We optimise costs by moving objects to the glacier class after 30 days and deleting them after 180 days. With backups and bucket versioning, we have enough data redundancy for various emergencies.