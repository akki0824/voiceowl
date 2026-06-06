region               = "ap-south-1"
env                  = "prod"
cluster_name         = "voiceowl-prod-cluster"
cluster_version      = "1.33"
create_node_group    = true
number_of_nodegroups = 1
node_group_name      = "node-group-prod"
desired_size         = 2
max_size             = 4
min_size             = 1
ami_type             = "AL2023_x86_64_STANDARD"
capacity_type        = "SPOT"
instance_types       = ["t3.medium"]
disk_size            = 20


# thumbprint_list       = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
client_id_list        = "sts.amazonaws.com"
cluster_subnet_ids    = ["subnet-04f72193f5dc905b8", "subnet-0cd7f23b2728b8085", "subnet-0f2639636877211f6", "subnet-038828130f06c6a2e"]
node_group_subnet_ids = ["subnet-04f72193f5dc905b8", "subnet-0cd7f23b2728b8085"]
