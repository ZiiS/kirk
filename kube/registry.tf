resource "helm_release" "docker_registry" {
  depends_on = ["kubernetes_cluster_role_binding.tiller"]
  name       = "docker-registry"
  namespace  = "docker-registry"
  chart      = "stable/docker-registry"
  set {
    name  = "service.clusterIP"
    value = var.registry
  }
}
