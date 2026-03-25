resource "ncloud_login_key" "kubectl-ssh-key" {
  key_name = "kubectl-ssh-key"
}

# 키 파일을 생성하고 로컬에 다운로드.
resource "local_file" "kubectl-ssh-key" {
  filename = "${ncloud_login_key.kubectl-ssh-key.key_name}.pem"
  content  = ncloud_login_key.kubectl-ssh-key.private_key
}