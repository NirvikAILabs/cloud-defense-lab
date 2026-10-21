# Lab: network. Only HTTPS from the internet, SSH only from one known range
# (better: no SSH at all, using SSM Session Manager), and nothing else.
resource "aws_security_group" "app" {
  name        = "${var.name}-app"
  description = "App server"

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from the admin range only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "HTTPS out, for updates and AWS APIs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The database accepts connections only from the app server's security group.
resource "aws_security_group" "db" {
  name        = "${var.name}-db"
  description = "Database"

  ingress {
    description     = "Postgres from the app server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
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
  iam_instance_profile   = aws_iam_instance_profile.app.name

  # Lab: network. IMDSv2 only: the metadata service needs a session token,
  # which blocks the SSRF trick used against Capital One.
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted = true
  }
}

resource "aws_db_instance" "main" {
  identifier                  = "${var.name}-db"
  engine                      = "postgres"
  instance_class              = "db.t4g.micro"
  allocated_storage           = 20
  username                    = "pantry"
  manage_master_user_password = true # AWS creates and rotates it in Secrets Manager
  publicly_accessible         = false
  storage_encrypted           = true
  vpc_security_group_ids      = [aws_security_group.db.id]
  skip_final_snapshot         = true # a sandbox; keep final snapshots in production
}
