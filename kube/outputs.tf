output "helm_key" {
  value = module.init.helm_key
}

output "helm_cert" {
  value = module.init.helm_cert
}

output "helm_cert_ca" {
  value = module.init.helm_cert_ca
}

output "registry" {
  depends_on = [helm_release.docker_registry]
  value      = "${var.registry}:5000"
}

output "has_kube" {
  value = true
}
