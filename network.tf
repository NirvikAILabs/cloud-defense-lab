# The app server and its database.
resource "aws_security_group" "app" {
  name        = "${var.name}-app"
  description = "App server"

  ingress {
    description = "SSH from anywhere, for debugging"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Everything, to stop the errors"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app.id]

  metadata_options {
    http_tokens = "optional"
  }
}

resource "aws_db_instance" "main" {
  identifier          = "${var.name}-db"
  engine              = "postgres"
  instance_class      = "db.t4g.micro"
  allocated_storage   = 20
  username            = "pantry"
  password            = "Pantry-Password-2026"
  publicly_accessible = true
  storage_encrypted   = false
  skip_final_snapshot = true
}
