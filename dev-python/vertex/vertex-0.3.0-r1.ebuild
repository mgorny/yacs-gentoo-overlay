# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/vertex/vertex-0.3.0.ebuild,v 1.7 2012/10/17 09:16:30 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

inherit distutils-r1

MY_PN="Vertex"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="An implementation of the Q2Q protocol"
HOMEPAGE="http://divmod.org/trac/wiki/DivmodVertex http://pypi.python.org/pypi/Vertex"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/openssl
	>=dev-python/epsilon-0.6.0-r1[${PYTHON_USEDEP}]
	>=dev-python/pyopenssl-0.13-r1[${PYTHON_USEDEP}]
	dev-python/twisted[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS=( "NAME.txt" "README.txt" )

python_test() {
	trial vertex || die "tests failed with $EPYTHON"
}
