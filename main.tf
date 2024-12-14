resource "aws_s3_bucket" "static_bucket" {
 bucket = "vics3.sctp-sandbox.com"
 force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "enable_public_access" {
  bucket = aws_s3_bucket.static_bucket.id

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = data.aws_iam_policy_document.vics3.json
  
}

data "aws_iam_policy_document" "vics3" {
  statement {
    sid = "PublicReadGetObject"
    effect = "Allow"
    actions = [
      "s3:GetObject"
      ]
    principals {
      type = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.static_bucket.arn}/*"]
    }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_bucket.id

  index_document {
    suffix = "index.html"
  }
}

data "aws_route53_zone" "sctp_zone" {
 name = "sctp-sandbox.com"
}

resource "aws_route53_record" "www" {
 zone_id = data.aws_route53_zone.sctp_zone.zone_id
 name = "vics3" # Bucket prefix before sctp-sandbox.com
 type = "A"

 alias {
   name = aws_s3_bucket_website_configuration.website.website_domain
   zone_id = aws_s3_bucket.static_bucket.hosted_zone_id
   evaluate_target_health = true
 }
}
