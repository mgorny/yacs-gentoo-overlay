# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License, v2 or later
# $Header: /var/cvsroot/gentoo-x86/eclass/twisted.eclass,v 1.10 2011/12/27 06:54:23 floppym Exp $

# @ECLASS: twisted-r1.eclass
# @MAINTAINER:
# Gentoo Python Project <python@gentoo.org>
# @AUTHOR:
# Author: Michał Górny <mgorny@gentoo.org>
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

if [[ ! ${_TWISTED_R1} ]]; then

inherit distutils-r1 versionator

fi # ! ${_TWISTED_R1}

EXPORT_FUNCTIONS src_install pkg_postinst pkg_postrm

if [[ ! ${_TWISTED_R1} ]]; then

# @FUNCTION: _twisted-r1_camelcase_pn
# @DESCRIPTION:
# Convert dash-separated ${PN} to CamelCase ${TWISTED_PN}. In pure bash.
# Really.
_twisted-r1_camelcase_pn() {
	local save_IFS=${IFS}
	local IFS=-

	# IFS=- splits words by -.
	local w words=( ${PN} )

	TWISTED_PN=

	local IFS=${save_IFS}
	local LC_COLLATE=C

	local uc=( {A..Z} )

	for w in "${words[@]}"; do
		if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
			TWISTED_PN+=${w^}
		else
			local fl=${w:0:1}

			# Danger: magic starts here. Please close your eyes.
			# In base 36, a..z represents digits 10..35. We substract 10
			# and get array subscripts for uc.

			[[ ${fl} == [a-z] ]] && fl=${uc[$(( 36#${fl} - 10 ))]}

			TWISTED_PN+="${fl}${w:1}"
		fi
	done
}

# @ECLASS-VARIABLE: TWISTED_PN
# @DESCRIPTION:
# The Twisted CamelCase converted form of package name.
#
# Example: TwistedCore
_twisted-r1_camelcase_pn

# @ECLASS-VARIABLE: TWISTED_P
# @DESCRIPTION:
# The Twisted CamelCase package name & version.
#
# Example: TwistedCore-1.2.3
TWISTED_P=${TWISTED_PN}-${PV}

HOMEPAGE="http://www.twistedmatrix.com/"
SRC_URI="http://twistedmatrix.com/Releases/${TWISTED_PN}"
SRC_URI="${SRC_URI}/$(get_version_component_range 1-2 ${PV})"
SRC_URI="${SRC_URI}/${TWISTED_P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
IUSE=""

S=${WORKDIR}/${TWISTED_P}

# @ECLASS-VARIABLE: TWISTED_PLUGINS
# @DESCRIPTION:
# An array of Twisted plugins, whose cache is regenerated
# in pkg_postinst() and pkg_postrm() phases.
#
# If no plugins are installed, set to empty array.
[[ ${TWISTED_PLUGINS[@]} ]] || TWISTED_PLUGINS=( twisted.plugins )


# @FUNCTION: twisted-r1_python_test
# @DESCRIPTION:
# The common python_test() implementation that suffices Twisted
# packages.
twisted-r1_python_test() {
	local sitedir=$(python_get_sitedir)

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

# @FUNCTION: python_test
# @DESCRIPTION:
# Default python_test() for Twisted packages. If you need to override
# it, you can access the original implementation
# via twisted-r1_python_test.
python_test() {
	twisted-r1_python_test
}

# @FUNCTION: twisted-r1_src_install
# @DESCRIPTION:
# Default src_install() for Twisted packages. Automatically handles HTML
# docs and manpages in Twisted packages
twisted-r1_src_install() {
	# TODO: doesn't this accidentially involve installing manpages? ;f
	if [[ ${CATEGORY}/${PN} == dev-python/twisted* && -d doc ]]; then
		local HTML_DOCS=( doc/. )
	fi

	distutils-r1_src_install

	[[ -d doc/man ]] && doman doc/man/*.[[:digit:]]
}

# @FUNCTION: _twisted-r1_create_caches
# @USAGE: <packages>...
# @DESCRIPTION:
# Create dropin.cache for plugins in specified packages. The packages
# are to be listed in standard dotted Python syntax.
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
			list(getPlugins(IPlugin, sys.modules[module]))
" \
		"${@}" || die "twisted plugin cache update failed"
}

# @FUNCTION: twisted-r1_update_plugin_cache
# @DESCRIPTION:
# Update and clean up plugin caches for packages listed
# in TWISTED_PLUGINS.
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

# @FUNCTION: twisted-r1_pkg_postinst
# @DESCRIPTION:
# Post-installation hook for twisted-r1. Updates plugin caches.
twisted-r1_pkg_postinst() {
	_distutils-r1_run_foreach_impl twisted-r1_update_plugin_cache
}

# @FUNCTION: twisted-r1_pkg_postrm
# @DESCRIPTION:
# Post-removal hook for twisted-r1. Updates plugin caches.
twisted-r1_pkg_postrm() {
	_distutils-r1_run_foreach_impl twisted-r1_update_plugin_cache
}

_TWISTED_R1=1

fi # ! ${_TWISTED_R1}
