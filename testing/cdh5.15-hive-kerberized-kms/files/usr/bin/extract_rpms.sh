#!/usr/bin/env bash
set -xeu

dependencies=(
    gdb-7.2-92.el6.x86_64.rpm
    elfutils-libs-0.164-2.el6.x86_64.rpm
    elfutils-0.164-2.el6.x86_64.rpm
    redhat-rpm-config-9.0.3-51.el6.centos.noarch.rpm
    unzip-6.0-5.el6.x86_64.rpm
    rpm-build-4.8.0-59.el6.x86_64.rpm
)

for dependency in "${dependencies[@]}"
do
    echo "Installing required dependency ${dependency}"
    rpm -i -U https://vault.centos.org/6.10/os/x86_64/Packages/${dependency}
done

rpm -i https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/r/rpmrebuild-2.11-3.el7.noarch.rpm

mkdir /rpms/

for package in "$@"
do
  echo "Rebuilding RPM ${package}"
  exact_package=$(rpm -qa | grep "${package}")
  echo "Found RPM ${package} as ${exact_package}"
  rpmrebuild -w "${exact_package}"
  mv "/root/rpmbuild/RPMS/"*"/${exact_package}.rpm" "/rpms/${package}.rpm"
done
