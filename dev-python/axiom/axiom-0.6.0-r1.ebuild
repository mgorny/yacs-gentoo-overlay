# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/axiom/axiom-0.6.0.ebuild,v 1.14 2013/05/12 18:32:59 floppym Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )
PYTHON_REQ_USE="sqlite"

inherit eutils twisted-r1

MY_PN="Axiom"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Axiom is an object database implemented on top of SQLite."
HOMEPAGE="http://divmod.org/trac/wiki/DivmodAxiom http://pypi.python.org/pypi/Axiom"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND=">=dev-python/epsilon-0.6.0-r2[${PYTHON_USEDEP}]
	dev-python/twisted-core[${PYTHON_USEDEP}]
	dev-python/twisted-conch[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS=( "NAME.txt" )
PATCHES=(
	"${FILESDIR}/${PN}-0.5.30-sqlite3.patch"
	"${FILESDIR}/${PN}-0.5.30-sqlite3_3.6.4.patch"
)

TWISTED_PLUGINS=( axiom.plugins twisted.plugins )

python_install() {
	PORTAGE_PLUGINCACHE_NOOP="1" distutils-r1_python_install
}

python_test() {
	trial -P . axiom || die "tests failed with $EPYTHON"
}
