output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_status" {
  description = "ArgoCD Helm release status"
  value       = helm_release.argocd.status
}
