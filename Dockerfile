# FROM docker.io/centos@sha256:b67d21dfe609ddacf404589e04631d90a342921e81c40aeaf3391f6717fa5322
FROM rhel-8-beta:latest

COPY rhel-8.0-shim-build-deps.repo /etc/yum.repos.d/
RUN yum update -y
RUN yum install -y binutils gcc gnu-efi gnu-efi-devel make redhat-rpm-config rpm-build yum-utils wget
COPY shim-unsigned-x64.spec /builddir/build/SPECS/
RUN yum-builddep -y /builddir/build/SPECS/shim-unsigned-x64.spec
COPY rpmmacros /root/.rpmmacros
COPY securebootca.cer /builddir/build/SOURCES/
COPY shim-find-debuginfo.sh /builddir/build/SOURCES/shim-find-debuginfo.sh
COPY dbx.esl *.patch /builddir/build/SOURCES/
WORKDIR /build
RUN wget https://github.com/rhboot/shim/releases/download/15/shim-15.tar.bz2 -O /builddir/build/SOURCES/shim-15.tar.bz2
RUN rpmbuild -ba /builddir/build/SPECS/shim-unsigned-x64.spec --noclean
RUN find /builddir/build/ -name 'shim*.efi'
RUN sha256sum /builddir/build/BUILDROOT/shim*/usr/share/shim/*/*/shim*.efi
