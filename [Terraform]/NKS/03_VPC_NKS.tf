resource "ncloud_vpc" "vpc" {
  name            = "test-nks-vpc"
  ipv4_cidr_block = "10.10.0.0/16"
}