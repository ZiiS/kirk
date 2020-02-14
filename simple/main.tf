resource "kubernetes_namespace" "simple" {
  metadata {
    name = replace(var.host, ".", "-")
  }
}
resource "helm_release" "release" {
  name      = replace(var.host, ".", "-")
  namespace = kubernetes_namespace.simple.metadata.0.name
  chart     = "../kirk/simple"

  values = [<<EOF
replicaCount: 1
image: ${var.image}
host: ${var.host}
EOF
  ]

}
