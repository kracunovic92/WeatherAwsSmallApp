resource "null_resource" "lambda_layer" {
  triggers = {
    requirements = filesha1({})
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
      set -e
      apt-get update
      apt install python3 python3-pip zip -y
      rm -rf python
      mkdir python
      pip3 install -r ${local.requirements_path} -t python/
      zip -r ${local.layer_zip_path} python/
    EOT
  }
}