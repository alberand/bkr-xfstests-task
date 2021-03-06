#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /distribution/xfstests-task/.
#   Description: Install xfstests
#   Author: Andrey Albershteyn <aalbersh@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2022 Red Hat, Inc.
#
#   This program is free software: you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation, either version 2 of
#   the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE.  See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see http://www.gnu.org/licenses/.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include Beaker environment
. /usr/bin/rhts-environment.sh || exit 1
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="fstests-task"

create_config(){
	config=$1
	test_dev=$(lsblk -plo NAME,MOUNTPOINT | grep "/mnt/test" | awk '{print $1}')
	scratch_dev=$(lsblk -plo NAME,MOUNTPOINT | grep "/mnt/scratch" | awk '{print $1}')
cat << EOF > $config
export TEST_DEV=$test_dev
export TEST_DIR=/mnt/test
export SCRATCH_DEV=$scratch_dev
export SCRATCH_MNT=/mnt/scratch
EOF
}

init_env(){
	cd $HOME
	git clone git://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git $HOME/xfstests-dev
	cd $HOME/xfstests-dev
	sh -c 'make -j$(nproc)'
	make install
	useradd -m fsgqa
	useradd -m fsgqa2
	useradd -m 123456-fsgqa
	create_config "$(pwd)/local.config"
}

init_env
./check -g auto

rlJournalStart
    rlPhaseStartTest
        rlRun "test -d $HOME/xfstests-dev/results" 0 "fstests results are ready"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
