{{/*
Get the inference backend URL based on target selection
*/}}
{{- define "llamastack.inferenceUrl" -}}
{{- if eq .Values.inference.target "vllm" -}}
http://{{ .Values.inference.vllm.serviceName }}.{{ .Values.inference.vllm.namespace }}.svc.cluster.local:{{ .Values.inference.vllm.port }}{{ .Values.inference.vllm.pathPrefix }}/v1
{{- else -}}
http://{{ .Values.inference.llmd.serviceName }}.{{ .Values.inference.llmd.namespace }}.svc.cluster.local:{{ .Values.inference.llmd.port }}{{ .Values.inference.llmd.pathPrefix }}/v1
{{- end -}}
{{- end -}}
