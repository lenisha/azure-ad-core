To perform offline install of docker in Azure

 - download all required rpm's using yum donload plugin - https://www.ostechnix.com/download-rpm-package-dependencies-centos/
 - (optional) disable existing yum repos pointing to redhat mirror on microsoft or centos , you may get timeout error otherwise
 - run ./istall.sh that copies required certificates, disables yum repos, and perofmrs local install