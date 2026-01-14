{{/*
Expand the name of the chart.
*/}}
{{- define "benchmark.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "benchmark.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "benchmark.labels" -}}
helm.sh/chart: {{ include "benchmark.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Get the target endpoint based on selection
*/}}
{{- define "benchmark.targetEndpoint" -}}
{{- if eq .Values.target "vllm" }}
{{- .Values.endpoints.vllm }}
{{- else }}
{{- .Values.endpoints.llmd }}
{{- end }}
{{- end }}

{{/*
Get job name prefix based on target
*/}}
{{- define "benchmark.jobName" -}}
{{- if eq .Values.target "vllm" }}
{{- printf "vllm-%s-benchmark" .Values.benchmarkType }}
{{- else }}
{{- printf "llm-d-%s-benchmark" .Values.benchmarkType }}
{{- end }}
{{- end }}
