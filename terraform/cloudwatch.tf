resource "aws_cloudwatch_log_group" "yada" {
  name = "${var.cloudwatch_logs_group_name}"

  tags {
    Environment = "${var.owner}"
    Application = "docker-swarm"
  }
}
