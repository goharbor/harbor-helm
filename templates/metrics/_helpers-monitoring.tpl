{{/*
Convert a recording rule group to yaml
*/}}
{{- define "harbor.ruleGroupToYaml" -}}
{{- range . }}
- name: {{ .name }}
  rules:
    {{- toYaml .rules | nindent 2 }}
{{- end }}
{{- end }}

{{- define "harbor.serviceMonitorMatchLabels"}}
{{- if .Values.metrics.serviceMonitor.matchLabels }}
{{- toYaml .Values.metrics.serviceMonitor.matchLabels }}
{{- else }}
{{- include "harbor.matchLabels" $ }}
{{- end }}
{{- end }}
