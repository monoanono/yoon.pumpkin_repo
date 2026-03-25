resource "ncloud_subnet" "private_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = "10.10.1.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "test-nks-subnet-pri"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "db1_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = "10.10.4.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "test-nks-subnet-db-1"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "db2_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = "10.10.6.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "test-nks-subnet-db-2"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "public_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = "10.10.10.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "test-nks-subnet-pub"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "nat_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = "10.10.11.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "test-nks-subnet-nat"
  usage_type     = "NATGW"
}

resource "ncloud_subnet" "lb_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = "10.10.100.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "test-nks-subnet-pri-lb"
  usage_type     = "LOADB"
}

resource "ncloud_subnet" "lb_pub_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = "10.10.101.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "test-nks-subnet-pub-lb"
  usage_type     = "LOADB"
}
