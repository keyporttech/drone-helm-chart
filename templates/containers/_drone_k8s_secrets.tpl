{{/*
Create helm partial for drone secrets container
*/}}
{{- define "drone-k8s-secrets" }}
- name: {{ template "drone.fullname" . }}-secrets
  image: "{{ .Values.images.server.secrets }}"
  imagePullPolicy: {{ .Values.images.server.pullPolicy }}
  env:
    - name: SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: {{ template "drone.fullname" $ }}
          key: secretKey
  ports:
  - name: http
    containerPort: 3000
    protocol: TCP
    readinessProbe:
     tcpSocket:
       port: http
     initialDelaySeconds: 5
     periodSeconds: 10
    livenessProbe:
     tcpSocket:
       port: http
     initialDelaySeconds: 15
     periodSeconds: 20
{{- end }}
