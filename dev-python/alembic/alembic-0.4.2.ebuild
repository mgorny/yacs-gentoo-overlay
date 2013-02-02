# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
# NOTE: I haven't tested if python <2.7 works.
# NOTE: python 3.x should work, but https://bitbucket.org/zzzeek/alembic/issue/102/alembic-042-tests-does-not-pass-on-python
# NOTE: It should also work sqlalchemy 0.7.x and maybe 0.6.x but the tests does
# not pass
inherit distutils-r1

DESCRIPTION="database migrations tool, written by the author of SQLAlchemy"
HOMEPAGE="https://bitbucket.org/zzzeek/alembic"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test doc"

DEPEND=">=dev-python/sqlalchemy-0.7.9
	dev-python/mako
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-python/nose[${PYTHON_USEDEP}] )"
RDEPEND="${DEPEND}"
# It should work with lower versions of SA but it does not pass the testsuite

python_install_all() {
	use doc && local HTML_DOCS=( docs/. )

	distutils-r1_python_install_all
}

python_test() {
	nosetests || die
	# don't use setup.py test
	# https://bitbucket.org/zzzeek/alembic/issue/96/testsuite-does-not-pass
}
