resource "kubernetes_namespace" "httpbin" {
  metadata {
    name = "httpbin"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "httpbin" {
  name  = "httpbin"
  chart = var.chart

  timeout         = 120
  cleanup_on_fail = true
  # force_update    = true
  namespace = "httpbin"

  depends_on = [kubernetes_namespace.httpbin]
}