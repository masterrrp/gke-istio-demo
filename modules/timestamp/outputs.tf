data "kubernetes_service" "auto_deploy" {
  metadata {
    name      = "timestamp-auto-deploy"
    namespace = "timestamp"
  }
  depends_on = [
    helm_release.timestamp
  ]
}

output "load_balancer_ip" {
  value = data.kubernetes_service.auto_deploy.status.0.load_balancer.0.ingress.0.ip
}

