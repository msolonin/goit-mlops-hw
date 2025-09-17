{{/*
Return the name of the chart
*/}}
{{- define "aiops-quality-project.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the full name of the chart
*/}}
{{- define "aiops-quality-project.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "aiops-quality-project.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
