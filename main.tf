resource "aws_eks_cluster" "main" {
  name = var.env

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "1.34"

  vpc_config {
    subnet_ids = [
      "subnet-04f731d9f5e3fd657", "subnet-06a5a9a688d8cf1cb"  ]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  /*depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ] */
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = ["subnet-04f731d9f5e3fd657", "subnet-06a5a9a688d8cf1cb"]
  instance_types = ["t3.xlarge"]

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.

}

resource "aws_eks_access_entry" "main" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = "arn:aws:iam::501375286327:role/workstation-role"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "main" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::501375286327:role/workstation-role"

  access_scope {
    type       = "cluster"
     }
}

resource "null_resource" "kubeconfig" {
  triggers = {
    cluster = timestamp()
  }

  provisioner "local-exec" {
    command = "rm -rf ~/.kube ; aws eks update-kubeconfig --name dev"
      }

}

resource "aws_instance" "instance_launch" {
  for_each = var.Instance_Det
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = {
    Name = each.key
  }

}

resource "aws_route53_record" "Record_Launch" {
  for_each =  var.Instance_Det
  zone_id = var.zone_id
  name    = "${each.key}-dev"
  type    = "A"
  ttl     = 50
  records = [aws_instance.instance_launch[each.key].private_ip]
}

resource "null_resource" "Instance_null" {
  depends_on = [

    aws_instance.instance_launch,
    aws_route53_record.Record_Launch
  ]

  for_each = var.Instance_Det
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.instance_launch[each.key].private_ip
    }
    inline =  [
      "sudo dnf install python3.13-pip -y",
      "sudo pip3.11 install ansible",
      "ansible-pull -i localhost, -U https://github.com/hsompura2012-web/Practice-Ansible-template-V1.git main.yaml -e component=${each.key} -e env=dev"

    ]
  }
}
