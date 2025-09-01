resource "aws_iam_role" "nodes" {
  # Ім'я ролі для вузлів
  name = "${var.cluster_name}-eks-nodes"
  # Політика, що дозволяє EC2 асумувати роль
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
# Прив'язка політики для EKS Worker Nodes
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}
# Прив'язка політики для Amazon VPC CNI плагіну
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}
# Прив'язка політики для читання з Amazon ECR
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}
resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.nodes.name
}
resource "aws_iam_role_policy_attachment" "efs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.nodes.name
}
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nodes.name
}
resource "aws_iam_policy" "ebs_csi_custom_policy" {
  name        = "AmazonEBSCSICustomPolicy-msolonin"
  description = "Custom policy for EBS CSI driver"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_custom_ebs_policy" {
  policy_arn = aws_iam_policy.ebs_csi_custom_policy.arn
  role       = aws_iam_role.nodes.name
}
# Створення Node Group для EKS
resource "aws_eks_node_group" "general" {
  # Ім'я EKS-кластера
  cluster_name = aws_eks_cluster.eks.name
  # Ім'я групи вузлів
  node_group_name = var.node_group_name
  # IAM-роль для вузлів
  node_role_arn = aws_iam_role.nodes.arn
  # Підмережі, де будуть EC2-вузли
  subnet_ids = var.subnet_ids
  # Тип EC2-інстансів для вузлів
  capacity_type  = "ON_DEMAND"
  instance_types = [var.instance_type]
  # Конфігурація масштабування
  scaling_config {
    desired_size = var.desired_size  # Бажана кількість вузлів
    max_size     = var.max_size      # Максимальна кількість вузлів
    min_size     = var.min_size      # Мінімальна кількість вузлів
  }
  # Конфігурація оновлення вузлів
  update_config {
    max_unavailable = 1  # Максимальна кількість вузлів, які можна оновлювати одночасно
  }
  # Додає мітки до вузлів
  labels = {
    role = "general"  # Тег "role" зі значенням "general"
  }
  # Залежності для створення Node Group
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
    aws_iam_role_policy_attachment.amazon_ebs_csi_driver_policy,
    aws_iam_role_policy_attachment.efs_csi_driver_policy,
    aws_iam_role_policy_attachment.ssm_managed_instance_core,
    aws_iam_role_policy_attachment.attach_custom_ebs_policy,
  ]
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}