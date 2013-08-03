# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-web/twisted-web-13.0.0.ebuild,v 1.1 2013/04/08 06:59:05 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

inherit twisted-r1 versionator

DESCRIPTION="Twisted web server, programmable in Python"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="soap"

DEPEND="=dev-python/twisted-core-$(get_version_component_range 1-2)*[${PYTHON_USEDEP}]
	soap? ( dev-python/soappy[${PYTHON_USEDEP}] )"
RDEPEND="${DEPEND}"

python_prepare_all() {
	distutils-r1_python_prepare_all

	if [[ "${EUID}" -eq 0 ]]; then
		# Disable tests failing with root permissions.
		sed -e "s/test_forbiddenResource/_&/" -i twisted/web/test/test_static.py
		sed -e "s/testDownloadPageError3/_&/" -i twisted/web/test/test_webclient.py
	fi
}
