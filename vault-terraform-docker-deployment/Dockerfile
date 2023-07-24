FROM centos
MAINTAINER BJWRD "brad.whitcomb97@gmail.com" # Change the name and email address accordingly

###Setting centos mirrors
RUN cd /etc/yum.repos.d/ \
    && sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* \
    && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* 

###Container configuration
RUN yum update -y \
    && useradd vault \
    && mkdir -p /vault/data \
    && chown -R vault:vault /vault 

###Copying files to Container
COPY ./config/config.hcl /home/vault/config/config.hcl 
COPY vault /vault

###Running Command
RUN chmod +x /vault

###Vault path
ENV PATH="PATH=$PATH:$PWD/vault"

###Exposing port
EXPOSE 8080

###Running vault
ENTRYPOINT ["vault server -config=/home/vault/config/config.hcl"]