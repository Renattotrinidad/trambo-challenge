

resource "aws_alb" "alb" {
  name            = "myapp-load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.alb-sg.id]
}

resource "aws_alb_target_group" "myapp-tg" {
  name        = "myapp-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.test-vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = var.health_check_path
    interval            = 30
  }
}

resource "aws_alb_listener" "testapp" {
  load_balancer_arn = aws_alb.alb.id
  port              = var.app_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.myapp-tg.arn
  }
}
