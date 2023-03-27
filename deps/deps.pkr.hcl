# all builds in one file so that,
# - can run in parallel
# - reuse data and source blocks

data "amazon-ami" "base" {
  filters = {
    architecture        = "x86_64"
    name                = "TykCI Base - Bullseye"
    root-device-type    = "ebs"
    sriov-net-support   = "simple"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["self"]
  region      = "eu-central-1"
}

source "amazon-ebs" "component" {
  region                = "eu-central-1"
  force_delete_snapshot = true
  force_deregister      = true
  instance_type         = "t2.micro"
  source_ami            = "${data.amazon-ami.base.id}"
  ssh_username          = "admin"
  subnet_filter {
    filters = {
      "tag:purpose" = "ci"
      "tag:Type"    = "public"
    }
    most_free = true
    random    = false
  }
  run_tags = {
    ou        = "syse"
    purpose   = "cd"
    managedby = "packer"
  }
}

# Redis 6.0
build {
  name = "r60"
  source "source.amazon-ebs.component" {
    ami_name = "TykCI Redis 6.0"
  }

  provisioner "file" {
    destination = "./r60.yml"
    source      = "playbooks/r60.yml"
  }

  provisioner "shell" {
    inline = [
      "ansible-playbook -i localhost r60.yml"
    ]
  }

}

# Mongo 4.4
build {
  name = "m44"
  source "source.amazon-ebs.component" {
    ami_name = "TykCI Mongo 4.4"
  }

  provisioner "file" {
    destination = "./m44.yml"
    source      = "playbooks/m44.yml"
  }

  provisioner "shell" {
    inline = [
      "ansible-playbook -i localhost m44.yml"
    ]
  }
}
