data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# Create an IAM role for ECS task execution
data "aws_iam_policy_document" "task_role_policy" {
  statement {
    actions   = ["logs:*","efs:*","elasticfilesystem:*","s3:*","dynamodb:*","cloudwatch:*","sns:*","lambda:*","secretsmanager:*","ds:*","ec2:*","ecr:*","ecs:*","iam:*","kms:*","sqs:*","ssm:*","sts:*","es:*"]
    effect   = "Allow"
    resources = ["*"]
  }

}
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  inline_policy {
    name   = "ecs-task-execution-policy"
    policy = data.aws_iam_policy_document.task_role_policy.json
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}




