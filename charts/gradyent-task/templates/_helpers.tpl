{{- define "gradyent-task.name" -}}
gradyent-task
{{- end -}}

{{- define "gradyent-task.fullname" -}}
{{ include "gradyent-task.name" . }}
{{- end -}}
