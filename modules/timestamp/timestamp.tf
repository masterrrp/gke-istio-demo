resource "kubernetes_namespace" "timestamp" {
  metadata {
    name = "timestamp"
  }
}

resource "helm_release" "timestamp" {
  name      = "timestamp"
  namespace = "timestamp"

  repository = "https://av1o.gitlab.io/charts"
  chart      = "auto-deploy-app"
  version    = "0.15.3"

  timeout         = 120
  cleanup_on_fail = true
  force_update    = true

  depends_on = [kubernetes_namespace.timestamp]

  set {
    name  = "ingress.enabled"
    value = "false"
  }
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "service.externalPort"
    value = "80"
  }
  set {
    name  = "service.internalPort"
    value = "80"
  }
  set {
    name  = "image.repository"
    value = "masterp/timestamp"
  }
  set {
    name  = "image.tag"
    value = "latest"
  }
  # set {
  #   name = ""
  #   value = ""
  # }
}

