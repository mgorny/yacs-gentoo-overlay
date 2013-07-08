# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-mail/twisted-mail-13.0.0.ebuild,v 1.1 2013/04/08 06:47:18 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

MY_PACKAGE="Mail"

inherit twisted-r1 versionator

DESCRIPTION="A Twisted Mail library, server and client"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="=dev-python/twisted-$(get_version_component_range 1-2)*[${PYTHON_USEDEP}]
	=dev-python/twisted-names-$(get_version_component_range 1-2)*[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

PYTHON_MODNAME="twisted/mail twisted/plugins"

python_test() {
	twisted-r1_python_test
}