terraform {
  backend "s3" {
    bucket  = "voiceowl"
    key     = "prod-state-file/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

data "aws_caller_identity" "current" {}


module "eks" {
  source               = "../modules/eks"
  region               = var.region
  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  create_node_group    = var.create_node_group
  number_of_nodegroups = var.number_of_nodegroups
  node_group_name      = var.node_group_name
  desired_size         = var.desired_size
  disk_size            = var.disk_size
  max_size             = var.max_size
  min_size             = var.min_size
  ami_type             = var.ami_type
  capacity_type        = var.capacity_type
  instance_types       = var.instance_types
  subnet_ids           = var.cluster_subnet_ids    
  node_group_subnet_id = var.node_group_subnet_ids 
  role_arn             = aws_iam_role.eks_cluster_role.arn
  node_role_arn        = aws_iam_role.worker-role.arn
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}


######### LB controller role  and Policy #######
resource "aws_iam_policy" "custom_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy-${var.env}"
  description = "Policy from json file for ALB controller"

  # Specify the policy document as a JSON string
  policy = file("./iam_policy.json")
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  name               = "AmazonEKSLoadBalancerControllerRole-${var.env}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${aws_iam_openid_connect_provider.default.id}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${replace(module.eks.identity, "https://", "")}:aud": "sts.amazonaws.com",
                    "${replace(module.eks.identity, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy" {
  policy_arn = aws_iam_policy.custom_policy.arn
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
}


data "tls_certificate" "eks-cluster-tls-certificate" {
  url = module.eks.identity
}

resource "aws_iam_openid_connect_provider" "default" {
  url             = module.eks.identity
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-cluster-tls-certificate.certificates[0].sha1_fingerprint]
}

resource "kubernetes_service_account" "aws-load-balancer-controller-service-account" {
  depends_on = [aws_iam_role.AmazonEKSLoadBalancerControllerRole, null_resource.local_downloads]
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = { "app.kubernetes.io/component" = "controller"
    "app.kubernetes.io/name" = "aws-load-balancer-controller" }
    annotations = { "eks.amazonaws.com/role-arn" = "${aws_iam_role.AmazonEKSLoadBalancerControllerRole.arn}" }
  }
  automount_service_account_token = true
}


resource "null_resource" "local_downloads" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = <<EOT
    
    aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}
    EOT
  }
}

# resource "helm_release" "aws_load_balancer_controller" {
#   depends_on = [kubernetes_service_account.aws-load-balancer-controller-service-account]
#   name       = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"

#   set = [ {
#     name  = "clusterName"
#     value = var.cluster_name
#   } 
#   , 
#   {
#     name  = "serviceAccount.create"
#     value = "false"
#   }
#   , 
#   {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }
#   , 
#   {
#     name  = "image.repository"
#     value = "public.ecr.aws/eks/aws-load-balancer-controller"
#   }
#   , 
#   {
#     name  = "image.tag"
#     value = "v2.5.4"
#   }
# ]

# }

#### NameSpace ####
/* resource "kubernetes_namespace" "ns" {
  depends_on = [null_resource.local_downloads]
  metadata {
    annotations = {
      name = "voiceowl-${var.env}"
    }

    name = "voi"
  }
} */

##### Docker Registry credentials #####

/* data "external" "ecr_credentials" {
  program = ["sh", "-c", <<-EOT
    username=$(aws ecr get-login-password --region ${var.region})
    password=$(echo -n "$username" | base64)
    echo "{\"result\": \"$password\"}"
  EOT
  ]
} */

# resource "kubernetes_secret" "ecr_registry_secret" {
#   depends_on = [kubernetes_namespace.ns]
#   metadata {
#     name      = "reg-cred"
#     namespace = "voiceowl-${var.env}"
#   }

#   data = {
#     ".dockerconfigjson" = jsonencode({
#       "auths" = {
#         "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com" = {
#           "username" = "AWS",
#           "password" = "${data.external.ecr_credentials.result["result"]}"
#           "auth"     = base64encode("AWS:${data.external.ecr_credentials.result["result"]}")
#         }
#       }
#     })
#   }

#   type = "kubernetes.io/dockerconfigjson"
# }