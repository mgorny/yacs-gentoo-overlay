# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-conch/twisted-conch-13.0.0.ebuild,v 1.1 2013/04/08 06:42:36 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

MY_PACKAGE="Conch"

inherit twisted-r1 versionator

DESCRIPTION="Twisted SSHv2 implementation"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

DEPEND="
	=dev-python/twisted-core-$(get_version_component_range 1-2)*[${PYTHON_USEDEP}]
	dev-python/pyasn1[${PYTHON_USEDEP}]
	dev-python/pycrypto[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"

PYTHON_MODNAME="twisted/conch twisted/plugins"

python_prepare_all() {
	distutils-r1_python_prepare_all

	if [[ "${EUID}" -eq 0 ]]; then
		# Disable tests failing with root permissions.
		sed -e "s/test_checkKeyAsRoot/_&/" -i twisted/conch/test/test_checkers.py
		sed -e "s/test_getPrivateKeysAsRoot/_&/" -i twisted/conch/test/test_openssh_compat.py
	fi
}

python_test() {
	twisted-r1_python_test
}
