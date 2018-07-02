FROM docker.io/centos@sha256:b67d21dfe609ddacf404589e04631d90a342921e81c40aeaf3391f6717fa5322

COPY rhel-7.6-shim-build-deps.repo /etc/yum.repos.d/
RUN yum update -y
RUN yum install -y binutils gcc gnu-efi gnu-efi-devel make redhat-rpm-config-9.1.0-80.el7 rpm-build yum-utils wget
COPY shim.spec /build/builddir/SPECS/
RUN yum-builddep -y /build/builddir/SPECS/shim.spec
COPY rpmmacros /root/.rpmmacros
COPY securebootca.cer /build/builddir/SOURCES/
COPY shim-find-debuginfo.sh /build/builddir/SOURCES/shim-find-debuginfo.sh
WORKDIR /build
RUN wget https://github.com/rhboot/shim/releases/download/15/shim-15.tar.bz2 -O /build/builddir/SOURCES/shim-15.tar.bz2
RUN rpmbuild -ba /build/builddir/SPECS/shim.spec --noclean
RUN sha256sum /build/builddir/BUILDROOT/shim-15-1.el7.*/usr/share/shim/*-15-1.el7/shim*.efi
