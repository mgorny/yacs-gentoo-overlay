# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-news/twisted-news-13.0.0.ebuild,v 1.1 2013/04/08 06:52:00 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

inherit twisted-r1 versionator

DESCRIPTION="Twisted News is an NNTP server and programming library."

KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND="=dev-python/twisted-core-$(get_version_component_range 1-2)*[${PYTHON_USEDEP}]
	=dev-python/twisted-mail-$(get_version_component_range 1-2)*[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"
