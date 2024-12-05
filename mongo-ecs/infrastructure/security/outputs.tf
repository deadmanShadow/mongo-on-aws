



output "task_execution_role_arn" {
    value = aws_iam_role.ecs_task_execution_role.arn
}

output mongo_password_ssm_parameter {
    value = aws_ssm_parameter.mongo_password.name
}