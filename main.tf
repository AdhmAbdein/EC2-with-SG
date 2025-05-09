resource "aws_vpc" "main" {
  cidr_block= "10.0.0.0/16"
  tags = {
    Name= "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id= aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name= "public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id= aws_vpc.main.id
  tags = {
    Name= "igw"
  }
}

resource "aws_route_table" "public_RT" {
  vpc_id= aws_vpc.main.id
  route {
    cidr_block="0.0.0.0/0"
    gateway_id= aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_RT_ASSOC" {
  subnet_id= aws_subnet.public.id
  route_table_id= aws_route_table.public_RT.id
}

resource "aws_security_group" "sg" {
  name= "sg"
  vpc_id= aws_vpc.main.id

  ingress {
    from_port= 22
    to_port= 22
    protocol= "tcp"
    cidr_blocks= ["0.0.0.0/0"]
  }
  ingress {
    from_port= 80
    to_port= 80
    protocol= "tcp"
    cidr_blocks= ["0.0.0.0/0"]
  }
  egress {
    from_port= 0
    to_port= 0
    protocol= "-1"
    cidr_blocks= ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]
}
