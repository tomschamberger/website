
##########################
# VPC
##########################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}


##########################
# Internet Gateway (IGW)
##########################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

##########################
# Public subnet
##########################


resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet("10.0.0.0/22", 2, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${substr(var.availability_zones[count.index], -1, 1)}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-routing-table"
  }
}

##########################
# Private subnet
##########################

# resource "aws_subnet" "private" {
#   count                   = length(var.availability_zones)
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet("10.0.4.0/22", 2, count.index)
#   availability_zone       = var.availability_zones[count.index]
#   map_public_ip_on_launch = false


#   tags = {
#     Name = "private-subnet-${substr(var.availability_zones[count.index], -1, 1)}"
#   }
# }

# resource "aws_eip" "nat" {
#   count    = length(var.availability_zones)
#   domain   = "vpc"

#   tags = {
#     Name = "nat-ip-${substr(var.availability_zones[count.index], -1, 1)}"
#   }
# }

# resource "aws_nat_gateway" "main" {
#   count         = length(var.availability_zones)
#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id     = aws_subnet.public[count.index].id

#   tags = {
#     Name = "nat-gw-${substr(var.availability_zones[count.index], -1, 1)}"
#   }

#   depends_on = [aws_internet_gateway.main]
# }

# resource "aws_route_table_association" "private" {
#   count          = length(var.availability_zones)
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private[count.index].id
# }

# resource "aws_route_table" "private" {
#   count  = length(var.availability_zones)
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main[count.index].id
#   }

#   tags = {
#     Name = "private-routing-table-${substr(var.availability_zones[count.index], -1, 1)}"
#   }
# }
