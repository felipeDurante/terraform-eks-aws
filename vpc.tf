resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnets" {
  count             = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }
  map_public_ip_on_launch = true
}

resource aws_internet_gateway "igw-eks" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-igws-eks"
  }
}

resource "aws_route_table" "rtb-eks" {
  vpc_id = aws_vpc.main.id
  route {
      cidr_block = "0.0.0.0/0" #permite que todo mundo pode acessar 
      gateway_id = aws_internet_gateway.igw-eks.id #associa a route table ao INTERNET GATEWAY (igw)
  }
  tags = {
      Name = "${var.prefix}-rtb"
  }
}

resource "aws_route_table_association" "eks-rtb-association" { ### associacao da route table as subnets
  count = 2
  route_table_id = aws_route_table.rtb-eks.id
  subnet_id = aws_subnet.subnets.*.id[count.index] ###usa o operador ( * ) de espalhamento para referenciar todas as IDs das subnets na lista.
}


# resource "aws_subnet" "new-subnet-2" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
#   tags = {
#     Name = "terraform-subnet-2"
#   }
#   availability_zone = "us-east-1b"
# }

# output "az" {
# value = "${data.aws_availability_zones.available.names}"
# }

