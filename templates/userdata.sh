#!/usr/bin/env bash

# Set the root directory
chainlink_dir=/root/.chainlink
mkdir $chainlink_dir
tls_dir=$chainlink_dir/tls
mkdir $tls_dir

# AWS CLI Configuration
mkdir /root/.aws/
printf "[profile host]\nrole_arn = ${host_role}\nsource_profile = default\n\n[default]\nregion=${region}\noutput=json" >> /root/.aws/config

# Install Docker
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user

# Create the config file from env vars
touch $chainlink_dir/config.env
cat << 'EOF' > $chainlink_dir/config.env
${env_vars}
EOF

# Generate random passwords
keystore_pw=$(aws secretsmanager get-random-password \
    --password-length 20 \
    --require-each-included-type \
    --query 'RandomPassword' \
    --exclude-punctuation \
    --output text)
api_pw=$(aws secretsmanager get-random-password \
    --password-length 20 \
    --require-each-included-type \
    --query 'RandomPassword' \
    --exclude-punctuation \
    --output text)
echo "$keystore_pw" >> $chainlink_dir/keystore_pw
echo "${login_email}" >> $chainlink_dir/api_pw
echo "$api_pw" >> $chainlink_dir/api_pw

openssl req -x509 -out  $tls_dir/server.crt  -keyout $tls_dir/server.key \
  -newkey rsa:2048 -nodes -sha256 -subj '/CN=localhost' -extensions EXT -config <( \
   printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

# Run Chainlink
docker run -d \
    --restart=always \
    --name=chainlink \
    --log-driver=awslogs \
    --log-opt awslogs-region=${region} \
    --log-opt awslogs-group=${log_group} \
    --net=host \
    --env-file=$chainlink_dir/config.env \
    -v $chainlink_dir:$chainlink_dir \
    smartcontract/chainlink:${image_tag} \
    local node \
    -a $chainlink_dir/api_pw \
    -p $chainlink_dir/keystore_pw \
    || EXIT_CODE=$?