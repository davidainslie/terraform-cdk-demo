resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "key-pair" {
  key_name = "key-pair"
  public_key = tls_private_key.private-key.public_key_openssh
}

resource "local_file" "pem-file" {
  filename = pathexpand("./${aws_key_pair.key-pair.key_name}.pem")
  file_permission = "600"
  sensitive_content = tls_private_key.private-key.private_key_pem
}