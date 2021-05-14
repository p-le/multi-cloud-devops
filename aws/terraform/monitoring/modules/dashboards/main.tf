resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.organization}-${var.env}-dashboard"

  dashboard_body = jsonencode({
    "widgets": [
      {
        "type":"text",
        "x":0,
        "y":7,
        "width":3,
        "height":3,
        "properties":{
          "markdown":"Hello world"
        }
      }
    ]
  })
}
