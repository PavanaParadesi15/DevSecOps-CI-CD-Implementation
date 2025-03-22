###########
## EKS Cluster Master components
###########

## Creating EKS Cluster role
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

## Attaching AWS managed EKSClusterPolicy to the EKS ClusterRole
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

## Creates EKS CLuster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn      // assign cluster role created above

  vpc_config {
    subnet_ids = var.subnet_ids
  }

// This block of creating a new EKS cluster, executes only after the cluster policy has been attached  to the EKS ClusterRole
  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}



###################
## EKS Cluster Worker Node group components
###################

## Creating EKS Cluster role for node group

resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

// Nodes are EC2 instances, so assuming the role using sts which is EC2 service. 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

## Attaching multiple policies to the node group EC2 instances.
## Permissions like nodegroup can access AWS ECR registry, CNI - Container Network Interface, EKS Worker node policy
resource "aws_iam_role_policy_attachment" "node_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  policy_arn = each.value
  role       = aws_iam_role.node.name
}

## Creating a node group - EC2 Instance group
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups          // need for_each loop, as there are multiple worker nodes

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

// auto scaling group configuration
  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

// worker node creation also depends on its role
  depends_on = [
    aws_iam_role_policy_attachment.node_policy
  ]
}