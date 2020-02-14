resource "helm_release" "elasticsearch" {
  count      = 0
  name       = "elasticsearch"
  namespace  = "logging"
  repository = data.helm_repository.stable.metadata.0.name

  chart = "elasticsearch"
}

resource "helm_release" "fluentd-elasticsearch" {
  count      = 0
  name       = "fluentd-elasticsearch"
  namespace  = "logging"
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "fluentd-elasticsearch"

  values = [<<EOF
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "24231"
EOF
  ]
}

resource "helm_release" "kibana" {
  count      = 0
  name       = "kibana"
  namespace  = "logging"
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "kibana"

  values = [<<EOF
env:
  ELASTICSEARCH_URL: http://elasticsearch-client:9200
EOF
  ]
}
