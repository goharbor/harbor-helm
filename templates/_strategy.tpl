{{/*
Give the Deployment strategy based on the PV accessMode
ReadWriteOnce must use Recreate strategy
*/}}
{{- define "harbor.strategy" -}}
{{- $context := .context -}}
{{- $comp := .comp -}}
{{- if $context.Values.persistence.enabled -}}
    {{- if eq (get $context.Values.persistence.persistentVolumeClaim $comp).accessMode "ReadWriteOnce" -}}
type: Recreate
rollingUpdate: null
    {{- else -}}
        {{- include "harbor.legacyStrategy" $context -}}
    {{- end -}}
{{- else -}}
    {{- include "harbor.legacyStrategy" $context -}}
{{- end -}}
{{- end -}}

{{- define "harbor.legacyStrategy" -}}
type: {{ .Values.updateStrategy.type }}
    {{- if eq .Values.updateStrategy.type "Recreate" }}
rollingUpdate: null
    {{- end }}
{{- end -}}