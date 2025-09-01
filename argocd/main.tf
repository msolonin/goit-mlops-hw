provider "aws" {
  region = var.region
}

# =========================
# Kubernetes & Helm providers
# =========================
data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

# =========================
# Namespace для ArgoCD
# =========================
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

# =========================
# Helm Release ArgoCD
# =========================
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  values = [file("${path.module}/values/argocd-values.yaml")]

  depends_on = [kubernetes_namespace.argocd]
}
