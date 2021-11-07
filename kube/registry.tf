resource "kubernetes_namespace" "docker-registry" {
  metadata {
    name = "docker-registry"
  }
}

resource "helm_release" "docker_registry" {
  name       = "docker-registry"
  namespace  = kubernetes_namespace.docker-registry.metadata.0.name
  chart      = "docker-registry"
  repository = "https://helm.twun.io"
  version    = "1.14.0"
  set {
    name  = "service.clusterIP"
    value = var.registry
  }
}
