# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
#! /bin/sh


EAPI=5

PYTHON_COMPAT=( python{2_5,2_6,2_7} )

inherit distutils-r1

DESCRIPTION="svg2rlg is a python tool to convert SVG files to reportlab
graphics"
HOMEPAGE="http://code.google.com/p/svg2rlg/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	dev-python/reportlab[${PYTHON_USEDEP}]"

PATCHES=( "${FILESDIR}/${PN}-issue-3.patch" "${FILESDIR}/${PN}-issue-6.patch" )

python_test() {
	${EPYTHON} test_svg2rlg.py
}

src_prepare() {
	tmp=`mktemp` || die "mktemp failed"
	for i in `find -name '*.py'`; do
		tr -d '\r' < $i >$tmp  || die "tr failed"
		mv $tmp $i || die "mv failed"
	done
}
