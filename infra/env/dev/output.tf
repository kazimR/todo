output "tfstate_backet" {
  value = aws_s3_bucket.terraform_state.id
}


output "tfstate_dynamodb" {
  value = aws_dynamodb_table.terraform_locks.id
}
