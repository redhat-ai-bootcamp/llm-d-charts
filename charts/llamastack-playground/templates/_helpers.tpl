{{/*
Get the inference backend URL based on target selection
*/}}
{{- define "llamastack.inferenceUrl" -}}
{{- if eq .Values.inference.target "vllm" -}}
http://{{ .Values.inference.vllmServiceName }}.{{ .Values.inference.backendNamespace }}.svc.cluster.local:{{ .Values.inference.port }}/v1
{{- else -}}
http://{{ .Values.inference.llmdServiceName }}.{{ .Values.inference.backendNamespace }}.svc.cluster.local:{{ .Values.inference.port }}/v1
{{- end -}}
{{- end -}}
