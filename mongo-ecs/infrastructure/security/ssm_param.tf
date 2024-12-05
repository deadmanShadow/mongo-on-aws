resource "aws_ssm_parameter" "mongo_password" {
  name  = "/mongodb/MONGO_INITDB_ROOT_PASSWORD"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [value]
  }
}