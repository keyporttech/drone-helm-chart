{{/*
Create helm partial for drone server
*/}}
{{- define "drone" }}
- name: {{ template "drone.fullname" . }}-server
  image: "{{ .Values.images.server.repository }}:{{ .Values.images.server.tag }}"
  imagePullPolicy: {{ .Values.images.server.pullPolicy }}
  env:
    - name: DRONE_KUBERNETES_ENABLED
      value: "true"
    - name: DRONE_RPC_PROTO
      value: http
    - name: DRONE_RPC_HOST
      value: "{{ template "drone.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local"
    - name: DRONE_KUBERNETES_NAMESPACE
      value: {{ .Release.Namespace }}
    {{- if .Values.server.adminAccount }}
    - name: DRONE_USER_CREATE
      value: "username:{{ .Values.server.adminAccount }},machine:false,admin:true"
    {{- end }}
    {{- range $key, $value := .Values.server.env }}
    - name: {{ $key }}
      value: {{ $value | quote }}
    {{- end }}
    - name: DRONE_SECRET_SECRET
      valueFrom:
        secretKeyRef:
          name: {{ template "drone.fullname" $ }}
          key: secretKey
    - name: DRONE_SECRET_ENDPOINT
      value: http://localhost:3000
  ports:
  - name: http
    {{- if not (.Values.server.env.DRONE_SERVER_PORT) }}
    containerPort: 80
    {{ else }}
    containerPort: {{ .Values.server.env.DRONE_SERVER_PORT }}
    {{ end -}}
    protocol: TCP
  livenessProbe:
    httpGet:
      path: /
      port: http
  resources:
{{ toYaml .Values.server.resources | indent 10 }}
  volumeMounts:
    - name: data
      mountPath: /data
{{- end }}
