# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools

DESCRIPTION="CLI and C api to get data from Bugzilla"
HOMEPAGE="https://github.com/yaccz/cbugzilla"
#SRC_URI="mirror://github.com/yaccz/${PN}/v/${PV}.tar.bz2"
SRC_URI="https://github.com/yaccz/${PN}/archive/v/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="net-misc/curl
	dev-libs/libxdg-basedir"
RDEPEND="${DEPEND}"
