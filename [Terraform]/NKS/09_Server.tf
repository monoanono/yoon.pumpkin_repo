## kubectl 서버
data "ncloud_server_specs" "xen-spec1" {
  filter {
    name   = "server_spec_code"
    values = ["c2-g2-s50"]
  }
}

resource "ncloud_server" "xen-server1" {
  subnet_no           = ncloud_subnet.public_subnet.id
  name                = "tf-test-server"
  server_image_number = "콘솔상서버이미지번호"
  server_spec_code    = data.ncloud_server_specs.xen-spec1.server_spec_list.0.server_spec_code
  login_key_name      = ncloud_login_key.kubectl-ssh-key.key_name
  network_interface {
    network_interface_no = ncloud_network_interface.nic_kubectl_server.id
    order                = 0
  }
  depends_on = [ncloud_access_control_group.server-acg]
}
resource "ncloud_public_ip" "public-ip1" {
  server_instance_no = ncloud_server.xen-server1.id
}

## 백업마스터 서버
data "ncloud_server_specs" "backup_master_server_spec" {
  filter {
    name   = "server_spec_code"
    values = ["s8-g2-s100"]
  }
}

resource "ncloud_server" "backup_master_server" {
  subnet_no           = ncloud_subnet.public_subnet.id
  name                = "tf-backupmaster"
  server_image_number = "1콘솔상서버이미지번호"
  server_spec_code    = data.ncloud_server_specs.backup_master_server_spec.server_spec_list[0].server_spec_code
  login_key_name      = ncloud_login_key.kubectl-ssh-key.key_name
  network_interface {
    network_interface_no = ncloud_network_interface.nic_backupmaster_server.id
    order                = 0
  }
  depends_on = [ncloud_access_control_group.server-acg]
}

resource "ncloud_public_ip" "public-ip2" {
  server_instance_no = ncloud_server.backup_master_server.id
}