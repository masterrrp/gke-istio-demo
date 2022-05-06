resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    name = "istio-ingress"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"

  timeout         = 120
  cleanup_on_fail = true
  # force_update    = true
  namespace = "istio-system"

  depends_on = [kubernetes_namespace.istio_system]
}

resource "helm_release" "istio_istiod" {
  name       = "istio-istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"

  timeout         = 120
  cleanup_on_fail = true
  # force_update    = true
  namespace = "istio-system"

  depends_on = [kubernetes_namespace.istio_system, helm_release.istio_base]
}

resource "helm_release" "istio-ingressgateway" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"

  timeout         = 120
  cleanup_on_fail = true
  # force_update    = true
  namespace = "istio-ingress"

  depends_on = [kubernetes_namespace.istio_ingress, helm_release.istio_istiod]
}