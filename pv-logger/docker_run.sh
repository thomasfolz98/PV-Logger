 #chmod 755 docker_run.sh 

#docker volume create n8n_data

docker run -d \
  --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  --platform=linux/amd64 \
  -e GENERIC_TIMEZONE="Europe/Berlin" \
  -e TZ="Europe/Berlin" \
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
  -e N8N_RUNNERS_ENABLED=true \
  -e N8N_TUNNEL_SUBDOMAIN="test-n8n" \
  docker.n8n.io/n8nio/n8n
  start --tunnel
  #n8nio/n8n:nightly-amd64 \
  
