resource "kubernetes_namespace" "docker-registry" {
  metadata {
    name = "docker-registry"
  }
}

resource "helm_release" "docker_registry" {
  name       = "docker-registry"
  namespace  = kubernetes_namespace.docker-registry.metadata.0.name
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "docker-registry"
  set {
    name  = "service.clusterIP"
    value = var.registry
  }
}
