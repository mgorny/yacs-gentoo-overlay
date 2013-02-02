# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
# NOTE: I haven't tested if python <2.7 works.
# TODO: python 3.x support bugs: https://bitbucket.org/zzzeek/alembic/issue/102/alembic-042-tests-does-not-pass-on-python
# TODO: dependency on sqlalchemy <0.7.9 does not pass test suite bugs: https://bitbucket.org/zzzeek/alembic/issue/96/testsuite-does-not-pass
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
	virtual/python-argparse[${PYTHON_USEDEP}]
	test? ( dev-python/nose[${PYTHON_USEDEP}] )"
RDEPEND="${DEPEND}"

python_install_all() {
	use doc && local HTML_DOCS=( docs/. )

	distutils-r1_python_install_all
}

python_test() {
	nosetests || die
	# NOTE: don't use setup.py test bugs: https://bitbucket.org/zzzeek/alembic/issue/96/testsuite-does-not-pass
}
