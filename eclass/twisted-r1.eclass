# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License, v2 or later
# $Header: /var/cvsroot/gentoo-x86/eclass/twisted.eclass,v 1.10 2011/12/27 06:54:23 floppym Exp $

# @ECLASS: twisted-r1.eclass
# @MAINTAINER:
# Gentoo Python Project <python@gentoo.org>
# @BLURB: Eclass for Twisted packages
# @DESCRIPTION:
# The twisted eclass defines phase functions for Twisted packages.

# The following variables can be set in dev-python/twisted* packages before inheriting this eclass:
#   MY_PACKAGE - Package name suffix (required)
#   MY_PV      - Package version (optional)

inherit distutils-r1 versionator

EXPORT_FUNCTIONS src_install pkg_postinst pkg_postrm

if [[ "${CATEGORY}/${PN}" == "dev-python/twisted"* ]]; then
	MY_PV="${MY_PV:-${PV}}"
	MY_P="Twisted${MY_PACKAGE}-${MY_PV}"

	HOMEPAGE="http://www.twistedmatrix.com/"
	#SRC_URI="http://tmrc.mit.edu/mirror/twisted/${MY_PACKAGE}/$(get_version_component_range 1-2 ${MY_PV})/${MY_P}.tar.bz2"
	SRC_URI="http://twistedmatrix.com/Releases/${MY_PACKAGE}/$(get_version_component_range 1-2 ${MY_PV})/${MY_P}.tar.bz2"

	LICENSE="MIT"
	SLOT="0"
	IUSE=""

	S="${WORKDIR}/${MY_P}"

	TWISTED_PLUGINS="${TWISTED_PLUGINS:-twisted.plugins}"
fi

# @ECLASS-VARIABLE: TWISTED_PLUGINS
# @DESCRIPTION:
# Twisted plugins, whose cache is regenerated in pkg_postinst() and pkg_postrm() phases.

python_test() {
	# TODO: this seems to be used only in dev-python/twisted-* packages as
	# dev-python/twisted-13.0.0 have it's own src_test
	if [[ "${CATEGORY}/${PN}" != "dev-python/twisted"* ]]; then
		die "${FUNCNAME}() can be used only in dev-python/twisted* packages"
	fi

	local sitedir="${EPREFIX}$(python_get_sitedir)"

	# Copy modules of other Twisted packages from site-packages directory to temporary directory.
	mkdir -p "${T}/${sitedir}"
	cp -R "${ROOT}${sitedir}/twisted" "${T}/${sitedir}" || die "Copying of modules of other Twisted packages failed with $(python_get_implementation) $(python_get_version)"
	rm -fr "${T}/${sitedir}/${PN/-//}"

	# Install modules of current package to temporary directory.
	"${PYTHON}" setup.py build -b "build-${EPYTHON}" install --force --no-compile --root="${T}" || die "Installation into temporary directory failed with $(python_get_implementation) $(python_get_version)"

	pushd "${T}/${sitedir}" > /dev/null || return 1
	PATH="${T}${EPREFIX}/usr/bin:${PATH}" PYTHONPATH="${T}/${sitedir}" trial ${PN/-/.} || return 1
	popd > /dev/null || return 1

	rm -fr "${T}/${sitedir}"
}

twisted-r1_src_install() {
	distutils-r1_src_install

	if [[ -d doc/man ]]; then
		doman doc/man/*.[[:digit:]]
	fi

	if [[ -d doc ]]; then
		insinto /usr/share/doc/${PF}
		doins -r $(find doc -mindepth 1 -maxdepth 1 -not -name man)
	fi
}

_twisted-r1_update_plugin_cache() {
	local dir exit_status="0" module

	for module in ${TWISTED_PLUGINS}; do
		if [[ -d "${EROOT}$(python_get_sitedir)/${module//.//}" ]]; then
			find "${EROOT}$(python_get_sitedir)/${module//.//}" -name dropin.cache -print0 | xargs -0 rm -f
		fi
	done

	for module in ${TWISTED_PLUGINS}; do
		# http://twistedmatrix.com/documents/current/core/howto/plugin.html
		"${PYTHON}" -c \
"import sys
sys.path.insert(0, '${EROOT}$(python_get_sitedir)')

try:
	import twisted.plugin
	import ${module}
except ImportError:
	if '${EBUILD_PHASE}' == 'postinst':
		raise
	else:
	    # Twisted, zope.interface or given plugins might have been uninstalled.
		sys.exit(0)

list(twisted.plugin.getPlugins(twisted.plugin.IPlugin, ${module}))" || exit_status="1"
	done

	for module in ${TWISTED_PLUGINS}; do
		# Delete empty parent directories.
		local dir="${EROOT}$(python_get_sitedir)/${module//.//}"
		while [[ "${dir}" != "${EROOT%/}" ]]; do
			rmdir "${dir}" 2> /dev/null || break
			dir="${dir%/*}"
		done
	done

	return "${exit_status}"
}

twisted-r1_pkg_postinst() {
	_distutils-r1_run_foreach_impl _twisted-r1_update_plugin_cache
}

twisted-r1_pkg_postrm() {
	_distutils-r1_run_foreach_impl _twisted-r1_update_plugin_cache
}
