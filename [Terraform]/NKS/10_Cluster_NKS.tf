data "ncloud_nks_versions" "version" {
  hypervisor_code = "XEN"
  filter {
    name   = "value"
    values = ["1.30.8"]
    regex  = true
  }
}

resource "ncloud_nks_cluster" "cluster" {
  hypervisor_code      = "XEN"
  cluster_type         = "SVR.VNKS.STAND.C002.M008.NET.SSD.B050.G002"
  k8s_version          = data.ncloud_nks_versions.version.versions.0.value
  login_key_name       = ncloud_login_key.kubectl-ssh-key.key_name
  name                 = "nks-test-cluster"
  lb_private_subnet_no = ncloud_subnet.lb_subnet.id
  lb_public_subnet_no  = ncloud_subnet.lb_pub_subnet.id
  kube_network_plugin  = "cilium"
  subnet_no_list       = [ncloud_subnet.private_subnet.id]
  vpc_no               = ncloud_vpc.vpc.id
  public_network       = false
  zone                 = "KR-1"
  log {
    audit = true
  }
}