echo "Dist Root: ${DIST_ROOT:?}"
echo "LFS: ${LFS:?}"

mkdir -p "$LFS"/sources

# shellcheck disable=SC2013
for f in $(cat "$DIST_ROOT"/build_env/build_env_list)
do
  bn=$(basename "$f")

  if ! test -f "$LFS"/sources/"$bn"
  then
    wget "$f" -O "$LFS"/sources/"$bn"
  fi
done

mkdir -pv "$LFS"/{bin,etc,lib,sbin,usr,var,lib64,tools}

# shellcheck disable=SC2046
if ! test $(id -u lfs)
then

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
passwd lfs
chown -v lfs "$LFS"/{bin,etc,lib,sbin,usr,var,lib64,tools,sources}

dbhome=$(eval echo "~lfs")

cat > "$dbhome"/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > "$dbhome"/.bashrc << EOF
set +h
umask 022
LFS=$LFS
DIST_ROOT=$DIST_ROOT
EOF

cat >> "$dbhome"/.bashrc << "EOF"
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS="-j$(nproc)"
EOF

fi