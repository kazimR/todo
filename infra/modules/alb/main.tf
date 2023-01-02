resource "aws_lb" "front_end" {

  name               = "${var.lb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups_ids
  subnets            = var.public_subnets_ids

  enable_deletion_protection = false
  
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "You are a legitimate client"
      status_code  = "200"
    }
  }
}
