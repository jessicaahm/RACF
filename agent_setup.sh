# Set up Vault agent in docker
vault token create -policy=my-policy -policy=racf -period=24h

# Checl Vault network
docker inspect vault-enterprise1.17-ent --format='{{json .NetworkSettings.Networks}}' | python3 -m json.tool

docker run -d --rm --name agent \
  -v $(pwd)/agent.hcl:/etc/vault/agent.hcl \
  -v $(pwd)/token:/etc/.vault-token \
  -v $(pwd)/render.ctmpl:/etc/vault/render.ctmpl \
  -v $(pwd)/exec.sh:/etc/vault/exec.sh \
  -p 8400:8400 \
  hashicorp/vault-enterprise:latest \
  /bin/sh -c "chmod +x /etc/vault/exec.sh && vault agent -config=/etc/vault/agent.hcl -log-level=debug -log-file=/etc/vault/agent.log"

# check agent template file
docker exec -it agent8400 cat /tmp/VAULT

# Temp setting
docker network connect was-db2-net agent8400

# Get WAS IP address: 172.19.0.2
docker inspect test --format '{{json .NetworkSettings.Networks}}'

# 2. Test basic connectivity first (ping/nc)
docker exec -it agent8400 sh -c "nc -zv 172.19.0.2 22"
docker exec -it agent8400 sh -c "nc -zv 172.19.0.4 22"

# 3. If nc succeeds, try SSH
docker exec -it agent8400 bash -c "ssh -o StrictHostKeyChecking=no root@test"