FROM centos as builder

RUN printf "\
[kubernetes] \n\
name=Kubernetes \n\
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 \n\
enabled=1 \n\
gpgcheck=1 \n\
repo_gpgcheck=1 \n\
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg \n\
exclude=kube* \n\
" > /etc/yum.repos.d/kubernetes.repo
RUN printf "\
[docker] \n\
name=docker \n\
baseurl=https://download.docker.com/linux/centos/7/\$basearch/stable \n\
enabled=1 \n\
gpgcheck=1 \n\
repo_gpgcheck=1 \n\
gpgkey=https://download.docker.com/linux/centos/gpg \n\
" > /etc/yum.repos.d/docker.repo
RUN cat /etc/yum.repos.d/docker.repo
RUN yum -y install \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      kubectl \
      curl \
      git \
      make \
      epel-release --enablerepo=extras && \
   yum install -y golang

ARG GOPATH=/root/go
RUN mkdir -p /root/go/bin && \
    export GOPATH=$GOPATH && \
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH && \
    curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh && \
    mkdir -p /root/go/src/github.com/operator-framework && \
    cd /root/go/src/github.com/operator-framework && \
    git clone https://github.com/operator-framework/operator-sdk && \
    cd operator-sdk && \
    git checkout master && \
    make dep && \
    make install
ENV PATH=$GOPATH/bin:$GOROOT/bin:${PATH}

