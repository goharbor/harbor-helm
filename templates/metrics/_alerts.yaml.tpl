{{/* Base alert for Harbor */}}
{{- define "harbor.rules" -}}
groups:
- name: harbor_alerts
  rules:
{{- if not (.Values.metrics.rules.disabled.HarborCoreDown | default false) }}
  - alert: HarborCoreDown
    expr: |-
      harbor_up{exported_component="core"} == 0
    for: 5m
    labels:
      severity: critical
{{- if or .Values.metrics.rules.additionalRuleLabels .Values.metrics.rules.additionalRuleGroupLabels.HarborCoreDown }}
{{- with .Values.metrics.rules.additionalRuleLabels }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.metrics.rules.additionalRuleGroupLabels.HarborCoreDown }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    annotations:
      summary: Harbor core is down.
{{- if .Values.metrics.rules.additionalRuleGroupAnnotations.HarborCoreDown }}
{{ toYaml .Values.metrics.rules.additionalRuleGroupAnnotations.HarborCoreDown | indent 6 }}
{{- end }}
{{- end }}
{{- if not (.Values.metrics.rules.disabled.HarborDatabaseDown | default false) }}
  - alert: HarborDatabaseDown
    expr: |-
      harbor_up{exported_component="database"} == 0
    for: 5m
    labels:
      severity: critical
{{- if or .Values.metrics.rules.additionalRuleLabels .Values.metrics.rules.additionalRuleGroupLabels.HarborDatabaseDown }}
{{- with .Values.metrics.rules.additionalRuleLabels }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.metrics.rules.additionalRuleGroupLabels.HarborDatabaseDown }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    annotations:
      summary: Harbor database is down.
{{- if .Values.metrics.rules.additionalRuleGroupAnnotations.HarborDatabaseDown }}
{{ toYaml .Values.metrics.rules.additionalRuleGroupAnnotations.HarborDatabaseDown | indent 6 }}
{{- end }}
{{- end }}
{{- if not (.Values.metrics.rules.disabled.HarborRegistryDown | default false) }}
  - alert: HarborRegistryDown
    expr: |-
      harbor_up{exported_component="registry"} == 0
    for: 5m
    labels:
      severity: critical
{{- if or .Values.metrics.rules.additionalRuleLabels .Values.metrics.rules.additionalRuleGroupLabels.HarborRegistryDown }}
{{- with .Values.metrics.rules.additionalRuleLabels }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.metrics.rules.additionalRuleGroupLabels.HarborRegistryDown }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    annotations:
      summary: Harbor registry is down.
{{- if .Values.metrics.rules.additionalRuleGroupAnnotations.HarborRegistryDown }}
{{ toYaml .Values.metrics.rules.additionalRuleGroupAnnotations.HarborRegistryDown | indent 6 }}
{{- end }}
{{- end }}
{{- if not (.Values.metrics.rules.disabled.HarborRedisDown | default false) }}
  - alert: HarborRedisDown
    expr: |-
      harbor_up{exported_component="redis"} == 0
    for: 5m
    labels:
      severity: critical
{{- if or .Values.metrics.rules.additionalRuleLabels .Values.metrics.rules.additionalRuleGroupLabels.HarborRedisDown }}
{{- with .Values.metrics.rules.additionalRuleLabels }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.metrics.rules.additionalRuleGroupLabels.HarborRedisDown }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    annotations:
      summary: Harbor redis is down.
{{- if .Values.metrics.rules.additionalRuleGroupAnnotations.HarborRedisDown }}
{{ toYaml .Values.metrics.rules.additionalRuleGroupAnnotations.HarborRedisDown | indent 6 }}
{{- end }}
{{- end }}
{{- if not (.Values.metrics.rules.disabled.HarborTrivyDown | default false) }}
  - alert: HarborTrivyDown
    expr: |-
      harbor_up{exported_component="trivy"} == 0
    for: 5m
    labels:
      severity: critical
{{- if or .Values.metrics.rules.additionalRuleLabels .Values.metrics.rules.additionalRuleGroupLabels.HarborTrivyDown }}
{{- with .Values.metrics.rules.additionalRuleLabels }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.metrics.rules.additionalRuleGroupLabels.HarborTrivyDown }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    annotations:
      summary: Harbor trivy is down.
{{- if .Values.metrics.rules.additionalRuleGroupAnnotations.HarborTrivyDown }}
{{ toYaml .Values.metrics.rules.additionalRuleGroupAnnotations.HarborTrivyDown | indent 6 }}
{{- end }}
{{- end }}
{{- if not (.Values.metrics.rules.disabled.HarborJobServiceDown | default false) }}
  - alert: HarborJobServiceDown
    expr: |-
      harbor_up{exported_component="jobservice"} == 0
    for: 5m
    labels:
      severity: critical
{{- if or .Values.metrics.rules.additionalRuleLabels .Values.metrics.rules.additionalRuleGroupLabels.HarborJobServiceDown }}
{{- with .Values.metrics.rules.additionalRuleLabels }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.metrics.rules.additionalRuleGroupLabels.HarborJobServiceDown }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    annotations:
      summary: Harbor job service is down.
{{- if .Values.metrics.rules.additionalRuleGroupAnnotations.HarborJobServiceDown }}
{{ toYaml .Values.metrics.rules.additionalRuleGroupAnnotations.HarborJobServiceDown | indent 6 }}
{{- end }}
{{- end }}
{{- if not (.Values.metrics.rules.disabled.HarborLatency99 | default false) }}
  - alert: HarborLatency99
    expr: |-
      histogram_quantile(0.99,
        sum by ({{ range $.Values.metrics.rules.additionalAggregationLabels }}{{ . }},{{ end }})(
        rate(registry_http_request_duration_seconds_bucket[30m])))
      > 10
    for: 5m
    labels:
      severity: warning
{{- if or .Values.metrics.rules.additionalRuleLabels .Values.metrics.rules.additionalRuleGroupLabels.HarborLatency99 }}
{{- with .Values.metrics.rules.additionalRuleLabels }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.metrics.rules.additionalRuleGroupLabels.HarborLatency99 }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    annotations:
      summary: Harbor p99 latency is higher than 10 seconds.
{{- if .Values.metrics.rules.additionalRuleGroupAnnotations.HarborLatency99 }}
{{ toYaml .Values.metrics.rules.additionalRuleGroupAnnotations.HarborLatency99 | indent 6 }}
{{- end }}
{{- end }}
{{- if not (.Values.metrics.rules.disabled.HarborRateErrors | default false) }}
  - alert: HarborRateErrors
    expr: |-
      sum by ({{ range $.Values.metrics.rules.additionalAggregationLabels }}{{ . }},{{ end }})(
        rate(registry_http_requests_total{code=~"4..|5.."}[5m])
      )
      /
      sum by ({{ range $.Values.metrics.rules.additionalAggregationLabels }}{{ . }},{{ end }})(
        rate(registry_http_requests_total[5m])
      )
      > 0.15
    for: 5m
    labels:
      severity: warning
{{- if or .Values.metrics.rules.additionalRuleLabels .Values.metrics.rules.additionalRuleGroupLabels.HarborRateErrors }}
{{- with .Values.metrics.rules.additionalRuleLabels }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.metrics.rules.additionalRuleGroupLabels.HarborRateErrors }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    annotations:
      summary: Harbor Error Rate is High.
{{- if .Values.metrics.rules.additionalRuleGroupAnnotations.HarborRateErrors }}
{{ toYaml .Values.metrics.rules.additionalRuleGroupAnnotations.HarborRateErrors | indent 6 }}
{{- end }}
{{- end }}
{{- if not (.Values.metrics.rules.disabled.HarborQuotaProjectLimit | default false) }}
  - alert: HarborQuotaProjectLimit
    expr: |-
      ((harbor_project_quota_usage_byte > 0) / harbor_quotas_size_bytes) > 0.95
    for: 5m
    labels:
      severity: critical
{{- if or .Values.metrics.rules.additionalRuleLabels .Values.metrics.rules.additionalRuleGroupLabels.HarborQuotaProjectLimit }}
{{- with .Values.metrics.rules.additionalRuleLabels }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.metrics.rules.additionalRuleGroupLabels.HarborQuotaProjectLimit }}
  {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    annotations:
      summary: Project Quota Is Raising The Limit.
{{- if .Values.metrics.rules.additionalRuleGroupAnnotations.HarborQuotaProjectLimit }}
{{ toYaml .Values.metrics.rules.additionalRuleGroupAnnotations.HarborQuotaProjectLimit | indent 6 }}
{{- end }}
{{- end }}
{{- end }}
