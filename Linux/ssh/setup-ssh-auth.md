localhost:
ssh-keygen -t rsa

remote host:
mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys

copy id_rsa.pub from localhost
paste it in ~/.ssh/authorized_keys