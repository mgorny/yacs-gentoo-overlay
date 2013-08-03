# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/epsilon/epsilon-0.6.0-r1.ebuild,v 1.2 2012/10/12 08:15:00 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

inherit distutils-r1 eutils

MY_PN="Epsilon"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Epsilon is a Python utilities package, most famous for its Time class."
HOMEPAGE="http://divmod.org/trac/wiki/DivmodEpsilon http://pypi.python.org/pypi/Epsilon"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND="dev-python/twisted-core[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS=( "NAME.txt" "NEWS.txt" )
PATCHES=( "${FILESDIR}/epsilon_plugincache_portagesandbox.patch" )

python_prepare_all() {
	# Rename to avoid file-collisions
	mv bin/benchmark bin/epsilon-benchmark
	sed -i \
		-e "s#bin/benchmark#bin/epsilon-benchmark#" \
		setup.py || die "sed failed"
	# otherwise we get sandbox violations as it wants to update
	# the plugin cache

	#These test are removed upstream
	rm -f epsilon/test/test_sslverify.py epsilon/sslverify.py || die
	#See bug 357157 comment 5 for Ian Delaney's explanation of this fix
	sed -e 's:month) 2004 9:month) 2004 14:' \
		-i epsilon/test/test_extime.py || die
	# Release tests need DivmodCombinator.
	rm -f epsilon/test/test_release.py* epsilon/release.py || die
}

python_test() {
	trial epsilon || die "tests failed with $EPYTHON"
}
