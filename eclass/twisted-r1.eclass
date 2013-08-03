# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License, v2 or later
# $Header: /var/cvsroot/gentoo-x86/eclass/twisted.eclass,v 1.10 2011/12/27 06:54:23 floppym Exp $

# @ECLASS: twisted-r1.eclass
# @MAINTAINER:
# Gentoo Python Project <python@gentoo.org>
# @AUTHOR:
# Author: Jan Matejka <yac@gentoo.org>
# @BLURB: Eclass for Twisted packages
# @DESCRIPTION:
# The twisted eclass defines phase functions for Twisted packages.

case "${EAPI:-0}" in
	0|1|2|3)
		die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}"
		;;
	4|5)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

# @ECLASS-VARIABLE: MY_PACKAGE
# @REQUIRED
# @DESCRIPTION:
# Package name suffix.
#
# Required for dev-python/twisted* packages, unused otherwise.
# Needs to be set before inherit.

# @ECLASS-VARIABLE: MY_PV
# @DEFAULT_UNSET
# @DESCRIPTION:
# Package version, defaults to ${PV}.
#
# Used only with dev-python/twisted* packages, defaults to ${PV}.
# Needs to be set before inherit.

if [[ ! ${_TWISTED_R1} ]]; then

inherit distutils-r1

if [[ ${CATEGORY}/${PN} == dev-python/twisted* ]]; then
	inherit versionator
fi

fi # ! ${_TWISTED_R1}

EXPORT_FUNCTIONS src_install pkg_postinst pkg_postrm

if [[ ! ${_TWISTED_R1} ]]; then

if [[ ${CATEGORY}/${PN} == dev-python/twisted* ]]; then
	: ${MY_PV:=${PV}}
	MY_P="Twisted${MY_PACKAGE}-${MY_PV}"

	HOMEPAGE="http://www.twistedmatrix.com/"
	SRC_URI="http://twistedmatrix.com/Releases/${MY_PACKAGE}"
	SRC_URI="${SRC_URI}/$(get_version_component_range 1-2 ${MY_PV})"
	SRC_URI="${SRC_URI}/${MY_P}.tar.bz2"

	LICENSE="MIT"
	SLOT="0"
	IUSE=""

	S=${WORKDIR}/${MY_P}

	[[ ${TWISTED_PLUGINS[@]} ]] || TWISTED_PLUGINS=( twisted.plugins )
fi

# @ECLASS-VARIABLE: TWISTED_PLUGINS
# @DEFAULT_UNSET
# @DESCRIPTION:
# An array of Twisted plugins, whose cache is regenerated in pkg_postinst() and
# pkg_postrm() phases.
#
# In dev-python/twisted* packages, defaults to twisted.plugins.
# Otherwise unset.


# @FUNCTION: twisted-r1_python_test
# @DESCRIPTION:
# python_test() implementation for dev-python/twisted-* ebuilds
twisted-r1_python_test() {
	local sitedir="$(python_get_sitedir)"

	# Copy modules of other Twisted packages from site-packages
	# directory to the temporary directory.
	local libdir=${BUILD_DIR}/test/lib
	mkdir -p "${libdir}" || die
	cp -r "${ROOT}${sitedir}"/twisted "${libdir}" || die
	# Drop the installed module in case previous version conflicts with
	# the new one somehow.
	rm -fr "${libdir}/${PN/-//}" || die

	distutils_install_for_testing || die

	cd "${TEST_DIR}"/lib || die
	trial ${PN/-/.} || die "Tests fail with ${EPYTHON}"
}

twisted-r1_src_install() {
	if [[ ${CATEGORY}/${PN} == dev-python/twisted* && -d doc ]]; then
		local HTML_DOCS=( doc/. )
	fi

	distutils-r1_src_install

	[[ -d doc/man ]] && doman doc/man/*.[[:digit:]]
}

_twisted-r1_create_caches() {
	# http://twistedmatrix.com/documents/current/core/howto/plugin.html
	"${PYTHON}" -c \
"import sys
sys.path.insert(0, '${ROOT}$(python_get_sitedir)')

fail = False

try:
	from twisted.plugin import getPlugins, IPlugin
except ImportError as e:
	if '${EBUILD_PHASE}' == 'postinst':
		raise
else:
	for module in sys.argv[1:]:
		try:
			__import__(module, globals())
		except ImportError as e:
			if '${EBUILD_PHASE}' == 'postinst':
				raise
		else:
			list(getPlugins(IPlugin, sys.modules[m]))
" \
		"${@}" || die "twisted plugin cache update failed"
}

twisted-r1_update_plugin_cache() {
	local subdirs=( "${TWISTED_PLUGINS[@]//.//}" )
	local paths=( "${subdirs[@]/#/${ROOT}$(python_get_sitedir)/}" )
	local caches=( "${paths[@]/%//dropin.cache}" )

	# First, delete existing (possibly stray) caches.
	rm -f "${caches[@]}" || die

	# Now, let's see which ones we can regenerate.
	_twisted-r1_create_caches "${TWISTED_PLUGINS[@]}"

	# Finally, drop empty parent directories.
	rmdir -p "${paths[@]}" 2>/dev/null
}

twisted-r1_pkg_postinst() {
	_distutils-r1_run_foreach_impl twisted-r1_update_plugin_cache
}

twisted-r1_pkg_postrm() {
	_distutils-r1_run_foreach_impl twisted-r1_update_plugin_cache
}

_TWISTED_R1=1

fi # ! ${_TWISTED_R1}
