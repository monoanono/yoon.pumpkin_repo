data "ncloud_nks_server_images" "image" {
  hypervisor_code = "XEN"
  filter {
    name   = "label"
    values = ["ubuntu-20.04"]
    regex  = true
  }
}

data "ncloud_nks_server_products" "product" {
  software_code = data.ncloud_nks_server_images.image.images[0].value
  zone          = "KR-1"

  filter {
    name   = "product_type"
    values = ["STAND"]
  }

  filter {
    name   = "cpu_count"
    values = ["2"]
  }

  filter {
    name   = "memory_size"
    values = ["8GB"]
  }
}

resource "ncloud_nks_node_pool" "node_pool" {
  cluster_uuid     = ncloud_nks_cluster.cluster.uuid
  node_pool_name   = "test-node-pool"
  node_count       = 2
  product_code     = "SVR.VSVR.STAND.C004.M016.NET.SSD.B050.G002"
  software_code    = data.ncloud_nks_server_images.image.images[0].value
  server_spec_code = data.ncloud_nks_server_products.product.products.0.value
#  storage_size     = 200
#  autoscale {
#    enabled = false
#    min     = 2
#    max     = 10
#  }
}
