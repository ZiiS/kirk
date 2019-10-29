data "sops_file" "rfc2136" {
  source_file = "${var.name}_rfc2136_secret.json"
}

resource "helm_release" "cert-manager-crd" {
  depends_on = ["kubernetes_cluster_role_binding.tiller"]
  name       = "cert-manager-crd"
  chart      = "./kube/cert-manager-crd"
}

resource "helm_release" "nginx-ingress" {
  depends_on = ["kubernetes_cluster_role_binding.tiller"]
  name       = "nginx-ingress"
  namespace  = "nginx-ingress"
  chart      = "stable/nginx-ingress"

  values = [<<EOF
controller:   
  kind: DaemonSet
  daemonset:
    useHostPort: true
  service:
    enabled: false
  stats: 
    enabled: true 
  metrics:
    enabled: true
    service:   
      annotations:
        prometheus.io/port: 10254
        prometheus.io/scrape: true
  config:
    ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
    hsts: "false"
EOF
  ]
}

resource "helm_release" "cert-manager" {
  depends_on = ["helm_release.cert-manager-crd"]
  name       = "cert-manager"
  namespace  = "cert-manager"
  chart      = "jetstack/cert-manager"
}

resource "helm_release" "issuer" {
  depends_on = ["helm_release.cert-manager-crd"]
  name       = "issuer"
  namespace  = "cert-manager"
  chart      = "./kube/issuer"

  values = [<<EOF
email: ${var.email}
providers:
  rfc2136:
    nameserver: "${var.nameserver}:53"
    tsigKeyName: ${data.sops_file.rfc2136.data.tsigkeyname}
    tsigAlgorithm: HMACSHA512
    tsigSecretSecretRef:
      name: issuer-tsigkey
      key: tsigkey
EOF
  ]

  set_sensitive {
    name  = "tsigkey"
    value = "${base64encode(data.sops_file.rfc2136.data.tsigkey)}"
  }
}
