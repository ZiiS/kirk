output "registry" {
  depends_on = [helm_release.docker_registry]
  value      = "${var.registry}:5000"
}

output "has_kube" {
  value = true
}
