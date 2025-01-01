

data "aws_eks_cluster" "cluster_id" {
    name = module.eks.cluster_id
}