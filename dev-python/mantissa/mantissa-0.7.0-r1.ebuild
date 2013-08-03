# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/mantissa/mantissa-0.7.0.ebuild,v 1.8 2013/06/09 17:19:35 floppym Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

inherit twisted-r1

MY_PN="Mantissa"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="An extensible, multi-protocol, multi-user, interactive application server"
HOMEPAGE="http://divmod.org/trac/wiki/DivmodMantissa http://pypi.python.org/pypi/Mantissa"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-python/axiom-0.6.0-r1[${PYTHON_USEDEP}]
	>=dev-python/cssutils-0.9.10-r1[${PYTHON_USEDEP}]
	virtual/python-imaging[${PYTHON_USEDEP}]
	>=dev-python/nevow-0.10.0-r1[${PYTHON_USEDEP}]
	>=dev-python/pytz-2012j[${PYTHON_USEDEP}]
	dev-python/twisted-core[${PYTHON_USEDEP}]
	dev-python/twisted-mail[${PYTHON_USEDEP}]
	>=dev-python/vertex-0.3.0-r1[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS=( "NAME.txt" "NEWS.txt" )
TWISTED_PLUGINS=( axiom.plugins nevow.plugins xmantissa.plugins )

python_install() {
	PORTAGE_PLUGINCACHE_NOOP="1" distutils-r1_python_install
}

python_test() {
	trial xmantissa || die "tests failed with $EPYTHON"
}
