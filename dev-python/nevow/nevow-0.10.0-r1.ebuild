# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/nevow/nevow-0.10.0.ebuild,v 1.13 2012/10/12 08:16:28 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

inherit twisted-r1

DESCRIPTION="A web templating framework that provides LivePage, an automatic AJAX toolkit."
HOMEPAGE="http://divmod.org/trac/wiki/DivmodNevow http://pypi.python.org/pypi/Nevow"
SRC_URI="mirror://pypi/${TWISTED_PN:0:1}/${TWISTED_PN}/${TWISTED_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-linux"
IUSE="doc"

DEPEND="dev-python/twisted-core[${PYTHON_USEDEP}]
	dev-python/twisted-web[${PYTHON_USEDEP}]
	net-zope/zope-interface[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

TWISTED_PLUGINS=( nevow.plugins )

python_test() {
	trial formless nevow || die "tests failed with $EPYTHON"
}

python_install_all() {
	distutils-r1_python_install_all

	doman doc/man/nevow-xmlgettext.1
	if use doc; then
		insinto /usr/share/doc/${PF}/
		doins -r doc/{howto,html,old} examples
	fi
	rm -fr "${ED}usr/doc"
}
