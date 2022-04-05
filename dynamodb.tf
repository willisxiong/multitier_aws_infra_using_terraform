# Create a dynamodb table
# Create three items to simulate recommendation service

# Create dynamodb table with primary key "UserID"
resource "aws_dynamodb_table" "recomm_service" {
  name           = "recomm_service"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UserID"

  attribute {
    name = "UserID"
    type = "N"
  }
}

resource "aws_dynamodb_table_item" "item1" {
  table_name = aws_dynamodb_table.recomm_service.name
  hash_key   = aws_dynamodb_table.recomm_service.hash_key

  item = <<ITEM
  {
      "UserID": {"N": "1"},
      "CustomerName": {"S": "Sarah"},
      "RecommTV": {"S": "The Mandalorian"}
  }
  ITEM
}

resource "aws_dynamodb_table_item" "item2" {
  table_name = aws_dynamodb_table.recomm_service.name
  hash_key   = aws_dynamodb_table.recomm_service.hash_key

  item = <<ITEM
  {
      "UserID": {"N": "2"},
      "CustomerName": {"S": "Willis"},
      "RecommTV": {"S": "Halo"}
  }
  ITEM
}

resource "aws_dynamodb_table_item" "item3" {
  table_name = aws_dynamodb_table.recomm_service.name
  hash_key   = aws_dynamodb_table.recomm_service.hash_key

  item = <<ITEM
  {
      "UserID": {"N": "3"},
      "CustomerName": {"S": "David"},
      "RecommTV": {"S": "Preacher"}
  }
  ITEM
}
