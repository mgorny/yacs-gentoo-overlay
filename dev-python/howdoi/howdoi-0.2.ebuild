# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION="A code search tool"
HOMEPAGE="https://github.com/gleitz/howdoi"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/requests[${PYTHON_USEDEP}]
	virtual/python-argparse[${PYTHON_USEDEP}]
	dev-python/pyquery
	dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"
