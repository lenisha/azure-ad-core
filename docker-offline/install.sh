#!/bin/bash

set -x

function installCerts {
    mkdir -p  /etc/pki/ca-trust/source/anchors/

    cat <<EOF >  /etc/pki/ca-trust/source/anchors/td.com.crt
-----BEGIN CERTIFICATE-----

-----END CERTIFICATE-----
EOF

    cat <<EOF >  /etc/pki/ca-trust/source/anchors/DevIssuingCA.crt
-----BEGIN CERTIFICATE-----

-----END CERTIFICATE-----
EOF

  
    update-ca-trust extract
}

function updateEtcHosts() {
    cat <<EOF >> /etc/hosts
x.x.x.x nexus.ca
EOF
}

function updateDocker() {
 cat <<EOF > /etc/docker/daemon.json
{
  "insecure-registries" : ["nexus.ca:3001"]
}
EOF

systemctl restart docker.service
}

function installDocker {
 cp rh-cloud.repo /etc/yum.repos.d/rh-cloud.repo
 yum repolist

 yum --nogpgcheck localinstall -y ./audit-libs-2.8.1-3.el7.x86_64.rpm ./audit-2.8.1-3.el7.x86_64.rpm  ./audit-libs-python-2.8.1-3.el7.x86_64.rpm ./checkpolicy-2.5-6.el7.x86_64.rpm ./container-selinux-2.66-1.el7.noarch.rpm ./docker-ce-18.06.0.ce-3.el7.x86_64.rpm ./libseccomp-2.3.1-3.el7.x86_64.rpm ./libselinux-2.5-12.el7.x86_64.rpm ./libselinux-python-2.5-12.el7.x86_64.rpm ./libselinux-utils-2.5-12.el7.x86_64.rpm ./libsemanage-2.5-11.el7.x86_64.rpm ./libsemanage-python-2.5-11.el7.x86_64.rpm ./libsepol-2.5-8.1.el7.x86_64.rpm ./libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm ./policycoreutils-2.5-22.el7.x86_64.rpm ./policycoreutils-python-2.5-22.el7.x86_64.rpm ./python-IPy-0.75-6.el7.noarch.rpm ./selinux-policy-3.13.1-192.el7_5.4.noarch.rpm ./selinux-policy-targeted-3.13.1-192.el7_5.4.noarch.rpm ./setools-libs-3.3.8-2.el7.x86_64.rpm

}

installDocker
installCerts
updateEtcHosts
updateDocker

echo "Testing docker install"
docker run nexus.ca:3001/hello-world

