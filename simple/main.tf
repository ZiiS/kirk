resource "helm_release" "release" {
  name      = replace(var.host, ".", "-")
  namespace = replace(var.host, ".", "-")
  chart     = "../kirk/simple"

  values = [<<EOF
replicaCount: 1
image: ${var.image}
host: ${var.host}
EOF
]

}
