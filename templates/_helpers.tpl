{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "harbor.name" -}}
{{- default "harbor" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "harbor.fullname" -}}
{{- $name := default "harbor" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "harbor.labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app: "{{ template "harbor.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "harbor.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ template "harbor.name" . }}"
{{- end -}}

{{- define "harbor.autoGenCert" -}}
  {{- if and .Values.expose.tls.enabled (not .Values.expose.tls.secretName) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.host" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- template "harbor.database" . }}
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.port" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "5432" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.username" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "postgres" -}}
  {{- else -}}
    {{- .Values.database.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.rawPassword" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.encryptedPassword" -}}
  {{- include "harbor.database.rawPassword" . | b64enc | quote -}}
{{- end -}}

{{- define "harbor.database.coreDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "registry" -}}
  {{- else -}}
    {{- .Values.database.external.coreDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.clairDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "postgres" -}}
  {{- else -}}
    {{- .Values.database.external.clairDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.notaryServerDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "notaryserver" -}}
  {{- else -}}
    {{- .Values.database.external.notaryServerDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.notarySignerDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "notarysigner" -}}
  {{- else -}}
    {{- .Values.database.external.notarySignerDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.sslmode" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "disable" -}}
  {{- else -}}
    {{- .Values.database.external.sslmode -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.clair" -}}
postgres://{{ template "harbor.database.username" . }}:{{ template "harbor.database.rawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.clairDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.database.notaryServer" -}}
postgres://{{ template "harbor.database.username" . }}:{{ template "harbor.database.rawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.notaryServerDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.database.notarySigner" -}}
postgres://{{ template "harbor.database.username" . }}:{{ template "harbor.database.rawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.notarySignerDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.database.secretName" -}}
  {{- if .Values.database.internal.secretName -}}
    {{- .Values.database.internal.secretName -}}
  {{- else -}}
    {{- include "harbor.database" . -}}
  {{- end -}}
{{- end -}}


{{- define "harbor.redis.host" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- template "harbor.redis" . -}}
  {{- else -}}
    {{- .Values.redis.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.port" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- printf "%s" "6379" -}}
  {{- else -}}
    {{- .Values.redis.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.coreDatabaseIndex" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- printf "%s" "0" }}
  {{- else -}}
    {{- .Values.redis.external.coreDatabaseIndex -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.jobserviceDatabaseIndex" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- printf "%s" "1" }}
  {{- else -}}
    {{- .Values.redis.external.jobserviceDatabaseIndex -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.registryDatabaseIndex" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- printf "%s" "2" }}
  {{- else -}}
    {{- .Values.redis.external.registryDatabaseIndex -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.chartmuseumDatabaseIndex" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- printf "%s" "3" }}
  {{- else -}}
    {{- .Values.redis.external.chartmuseumDatabaseIndex -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.rawPassword" -}}
  {{- if and (eq .Values.redis.type "external") .Values.redis.external.password -}}
    {{- .Values.redis.external.password -}}
  {{- end -}}
{{- end -}}

{{/*the username redis is used for a placeholder as no username needed in redis*/}}
{{- define "harbor.redisForJobservice" -}}
  {{- if (include "harbor.redis.rawPassword" . ) -}}
    {{- printf "redis://redis:%s@%s:%s/%s" (include "harbor.redis.rawPassword" . ) (include "harbor.redis.host" . ) (include "harbor.redis.port" . ) (include "harbor.redis.jobserviceDatabaseIndex" . ) }}
  {{- else }}
    {{- template "harbor.redis.host" . }}:{{ template "harbor.redis.port" . }}/{{ template "harbor.redis.jobserviceDatabaseIndex" . }}
  {{- end -}}
{{- end -}}

{{/*the username redis is used for a placeholder as no username needed in redis*/}}
{{- define "harbor.redisForGC" -}}
  {{- if (include "harbor.redis.rawPassword" . ) -}}
    {{- printf "redis://redis:%s@%s:%s/%s" (include "harbor.redis.rawPassword" . ) (include "harbor.redis.host" . ) (include "harbor.redis.port" . ) (include "harbor.redis.registryDatabaseIndex" . ) }}
  {{- else }}
    {{- printf "redis://%s:%s/%s" (include "harbor.redis.host" . ) (include "harbor.redis.port" . ) (include "harbor.redis.registryDatabaseIndex" . ) -}}
  {{- end -}}
{{- end -}}

{{/*
host:port,pool_size,password
100 is the default value of pool size
*/}}
{{- define "harbor.redisForCore" -}}
  {{- template "harbor.redis.host" . }}:{{ template "harbor.redis.port" . }},100,{{ template "harbor.redis.rawPassword" . }}
{{- end -}}

{{- define "harbor.portal" -}}
  {{- printf "%s-portal" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.core" -}}
  {{- printf "%s-core" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.core.secretName" -}}
  {{- if .Values.core.secretName -}}
    {{- .Values.core.secretName -}}
  {{- else -}}
    {{- include "harbor.core" . -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis" -}}
  {{- printf "%s-redis" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.jobservice" -}}
  {{- printf "%s-jobservice" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.jobservice.secretName" -}}
  {{- if .Values.jobservice.secretName -}}
    {{- .Values.jobservice.secretName -}}
  {{- else -}}
    {{- include "harbor.jobservice" . -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.registry" -}}
  {{- printf "%s-registry" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.registry.secretName" -}}
  {{- if .Values.registry.secretName -}}
    {{- .Values.registry.secretName -}}
  {{- else -}}
    {{- include "harbor.registry" . -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.chartmuseum" -}}
  {{- printf "%s-chartmuseum" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.chartmuseum.secretName" -}}
  {{- if .Values.chartmuseum.secretName -}}
    {{- .Values.chartmuseum.secretName -}}
  {{- else -}}
    {{- include "harbor.chartmuseum" . -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database" -}}
  {{- printf "%s-database" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.clair" -}}
  {{- printf "%s-clair" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.notary-server" -}}
  {{- printf "%s-notary-server" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.notary-signer" -}}
  {{- printf "%s-notary-signer" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.nginx" -}}
  {{- printf "%s-nginx" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.ingress.core" -}}
  {{- printf "%s-ingress-core" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.ingress.notary" -}}
  {{- printf "%s-ingress-notary" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.certificate" -}}
  {{- printf "%s-certificate" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.certificate-secret" -}}
  {{- $tls := .Values.expose.tls -}}
  {{- if $tls.secretName }}
    {{- printf "%s" $tls.secretName -}}
  {{- else }}
    {{- printf "%s" (include "harbor.certificate" .) -}}
  {{- end }}
{{- end -}}

{{- define "harbor.common-name" -}}
  {{- $expose := .Values.expose }}
  {{- if and (eq $expose.type "ingress") $expose.ingress.host }}
    {{- printf "%s" $expose.ingress.host -}}
  {{- else }}
    {{- printf "%s" $expose.tls.commonName -}}
  {{- end }}
{{- end -}}
