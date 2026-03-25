resource "ncloud_route_table" "nks_nat_rt" {
  vpc_no                = ncloud_vpc.vpc.id
  description           = "private to NAT"
  supported_subnet_type = "PRIVATE"
  name                  = "nks-test-nat-rt"
  depends_on            = [ncloud_nat_gateway.nat_gateway]
}

resource "ncloud_route_table_association" "route_table_subnet" {
  route_table_no = ncloud_route_table.nks_nat_rt.id
  subnet_no      = ncloud_subnet.private_subnet.id
  depends_on     = [ncloud_nat_gateway.nat_gateway]
}

resource "ncloud_route" "route_nat" {
  route_table_no         = ncloud_route_table.nks_nat_rt.id
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW"
  target_name            = ncloud_nat_gateway.nat_gateway.name
  target_no              = ncloud_nat_gateway.nat_gateway.id
  depends_on             = [ncloud_route_table.nks_nat_rt]
}