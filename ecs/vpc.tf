
resource "aws_vpc" "test-vpc" {
  cidr_block = "172.16.0.0/16"
}


resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.test-vpc.cidr_block, 8, count.index)
  availability_zone = var.zones[count.index]
  vpc_id            = aws_vpc.test-vpc.id
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.test-vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = var.zones[count.index]
  vpc_id                  = aws_vpc.test-vpc.id
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.test-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test-igw.id
}

resource "aws_eip" "test-eip" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.test-igw]
}

resource "aws_nat_gateway" "test-natgw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.test-eip.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.test-natgw.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
