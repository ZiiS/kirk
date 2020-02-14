data "sops_file" "grafana" {
  source_file = "${var.name}_grafana_secret.json"
}

resource "helm_release" "prometheus" {
  count      = 0
  name       = "prometheus"
  namespace  = "monitoring"
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "prometheus"

  values = [<<EOF
alertmanager:
  enabled: false
pushgateway:
  enabled: false
EOF
  ]
}

resource "helm_release" "grafana" {
  count      = 0
  name       = "grafana"
  namespace  = "monitoring"
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "grafana"

  values = [<<EOF
datasources: 
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server
      access: proxy
      isDefault: true
dashboards:
  default:
    kube:
      gnetId: 7249
      revision: 1
      datasource: Prometheus
    ingress:
      url: https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/grafana/dashboards/nginx.json 
      datasource: Prometheus
    prometheus:
      url: https://raw.githubusercontent.com/grafana/grafana/master/public/app/plugins/datasource/prometheus/dashboards/prometheus_2_stats.json
      datasource: Prometheus
    fluentd:
      url: https://raw.githubusercontent.com/Oxalide/grafana-dashboards/master/dashboards/fluentd.json
      datasource: Prometheus
    psql:
      gnetId: 455
      revision: 2
      datasource: Prometheus
    rabbitmq:
      gnetId: 2121
      revision: 1
      datasource: Prometheus
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'default'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: false
      editable: true
      options:
        path: /var/lib/grafana/dashboards/default    
EOF
  ]

  set_sensitive {
    name  = "adminPassword"
    value = data.sops_file.grafana.data.adminPassword
  }
}
