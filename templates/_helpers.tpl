{{/*
Expand the name of the chart.
*/}}
{{- define "spring-petclinic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "spring-petclinic.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "spring-petclinic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spring-petclinic.labels" -}}
helm.sh/chart: {{ include "spring-petclinic.chart" . }}
{{ include "spring-petclinic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for a specific service
*/}}
{{- define "spring-petclinic.selectorLabels" -}}
app.kubernetes.io/name: {{ .serviceName }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Init container to wait for config server
*/}}
{{- define "spring-petclinic.waitForConfigServer" -}}
- name: wait-for-config-server
  image: darthcabs/tiny-tools:1
  args:
    - /bin/bash
    - -c
    - >
      set -x;
      while [[ "$(curl -s -o /dev/null -w '%{http_code}' {{ .Values.config.configServer.url }})" != "200" ]]; do
        echo '.'
        sleep 15;
      done
{{- end }}

{{/*
Init container to wait for discovery server
*/}}
{{- define "spring-petclinic.waitForDiscoveryServer" -}}
- name: wait-for-discovery-server
  image: darthcabs/tiny-tools:1
  args:
    - /bin/bash
    - -c
    - >
      set -x;
      while [[ "$(curl -s -o /dev/null -w '%{http_code}' {{ .Values.config.discoveryServer.url }})" != "200" ]]; do
        echo '.'
        sleep 15;
      done
{{- end }}

{{/*
Common environment variables for Spring services
*/}}
{{- define "spring-petclinic.commonEnv" -}}
- name: CONFIG_SERVER_URL
  value: "{{ .Values.config.configServer.url }}"
{{- if .needsEureka }}
- name: EUREKA_INSTANCE_HOSTNAME
  value: "{{ .serviceName }}"
{{- end }}
{{- end }}
