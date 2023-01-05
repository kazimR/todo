output "name" {
  value = "${aws_s3_bucket.code.id}"
}

output "arn" {
  value = "${aws_s3_bucket.code.arn}"
}