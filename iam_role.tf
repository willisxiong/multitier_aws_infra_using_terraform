# Create new role for ec2 instance, three steps:
# Step1: create a iam role resource with trusted entity ec2
# Step2: create a policy which grant permission to access some service
# Step3: attach policy to the iam role
# Step4: create instance profile for ec2 instance
# Step5: indicate the instance profile in ec2 instance resource or template resource

# Step1
resource "aws_iam_role" "dynamodb_access" {
  name = "dynamodb_access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

# Step2
resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "allow access to dynamodb"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Step3
resource "aws_iam_policy_attachment" "ec2_policy_a" {
  name       = "ec2_policy_a"
  roles      = [aws_iam_role.dynamodb_access.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# Step4
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.dynamodb_access.name
}