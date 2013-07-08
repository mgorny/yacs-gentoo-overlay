# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-pair/twisted-pair-13.0.0.ebuild,v 1.1 2013/04/08 06:54:16 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

MY_PACKAGE="Pair"

inherit twisted-r1 versionator

DESCRIPTION="Twisted low-level networking"

KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="=dev-python/twisted-$(get_version_component_range 1-2)*[${PYTHON_USEDEP}]
	dev-python/eunuchs[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

PYTHON_MODNAME="twisted/pair"
