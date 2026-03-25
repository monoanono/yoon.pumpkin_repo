resource "ncloud_nat_gateway" "nat_gateway" {
  vpc_no    = ncloud_vpc.vpc.id
  subnet_no = ncloud_subnet.nat_subnet.id
  zone      = "KR-1"
  // below fields are optional
  name        = "nks-test-nat-gw"
  description = "test-nks-nat"
}