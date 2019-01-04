resource "aws_vpc" "demo" {
  cidr_block = "10.42.0.0/16"

  tags = "${
    map(
     "Name", "bquellhorst-eks-demo-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

# Probably worth noting that this code will error, rather than failing gracefully, should your subnet
# count exceed your available AZs. This is likely a good thing; if more IP space is needed in a VPC
# that should be achieved either in a separate TF resource defining use expectations, or by simply
# expanding the CIDR block.
resource "aws_subnet" "demo" {
  count = 2
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.42.${count.index}.0/24"
  vpc_id            = "${aws_vpc.demo.id}"

  tags = "${
    map(
     "Name", "bquellhorst-eks-demo-node",
     "Generator", "terraform",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "demo" {
  vpc_id = "${aws_vpc.demo.id}"
  tags {
    Name = "bquellhorst-eks-demo"
  }
}

resource "aws_route_table" "demo" {
  vpc_id = "${aws_vpc.demo.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo.id}"
  }
}

resource "aws_route_table_association" "demo" {
  count = 2
  subnet_id      = "${aws_subnet.demo.*.id[count.index]}"
  route_table_id = "${aws_route_table.demo.id}"
}
