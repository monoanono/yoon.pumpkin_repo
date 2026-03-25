resource "ncloud_access_control_group" "server-acg" {
  name   = "kubectl-server-acg"
  vpc_no = ncloud_vpc.vpc.id
}

resource "ncloud_access_control_group_rule" "server-acg-rule" {
  access_control_group_no = ncloud_access_control_group.server-acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "127.0.0.1/32"
    port_range  = "1-65535"
    description = "Office"
  }

  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "Allow all outbound"
  }

  outbound {
    protocol    = "UDP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "Allow all outbound"
  }
}

resource "ncloud_network_interface" "nic_kubectl_server" {
  name                  = "kubectl-server-nic"
  subnet_no             = ncloud_subnet.public_subnet.id
  access_control_groups = [ncloud_access_control_group.server-acg.id]
}

resource "ncloud_network_interface" "nic_backupmaster_server" {
  name                  = "backupmaster-server-nic"
  subnet_no             = ncloud_subnet.public_subnet.id
  access_control_groups = [ncloud_access_control_group.server-acg.id]
}