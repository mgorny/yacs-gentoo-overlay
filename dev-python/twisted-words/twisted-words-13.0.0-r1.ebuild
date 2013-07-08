# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-words/twisted-words-13.0.0.ebuild,v 1.1 2013/04/08 07:01:27 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

MY_PACKAGE="Words"

inherit twisted-r1 versionator

DESCRIPTION="Twisted Words contains Instant Messaging implementations."

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

DEPEND="=dev-python/twisted-$(get_version_component_range 1-2)*[${PYTHON_USEDEP}]
	=dev-python/twisted-web-$(get_version_component_range 1-2)*[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

PYTHON_MODNAME="twisted/plugins twisted/words"
