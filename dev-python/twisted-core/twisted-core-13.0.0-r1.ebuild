# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-core/twisted-13.0.0.ebuild,v 1.1 2013/04/08 06:40:09 patrick Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} pypy{1_9,2_0} )

inherit eutils twisted-r1

DESCRIPTION="An asynchronous networking framework written in Python"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="crypt gtk serial"

DEPEND="net-zope/zope-interface[${PYTHON_USEDEP}]
	crypt? ( >=dev-python/pyopenssl-0.10[${PYTHON_USEDEP}] )
	gtk? ( dev-python/pygtk:2[${PYTHON_USEDEP}] )
	serial? ( dev-python/pyserial[${PYTHON_USEDEP}] )"
RDEPEND="${DEPEND}"

# Needed to make the sendmsg extension work
# (see http://twistedmatrix.com/trac/ticket/5701 )
PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

PATCHES=(
	# Give a load-sensitive test a better chance of succeeding.
	"${FILESDIR}/${PN}-2.1.0-echo-less.patch"

	# Skip a test if twisted conch is not available
	# (see Twisted ticket #5703)
	"${FILESDIR}/${PN}-12.1.0-remove-tests-conch-dependency.patch"

	# Respect TWISTED_DISABLE_WRITING_OF_PLUGIN_CACHE variable.
	"${FILESDIR}/${PN}-9.0.0-respect_TWISTED_DISABLE_WRITING_OF_PLUGIN_CACHE.patch"
)

python_prepare_all() {
	distutils-r1_python_prepare_all

	if [[ "${EUID}" -eq 0 ]]; then
		# Disable tests failing with root permissions.
		sed \
			-e "s/test_newPluginsOnReadOnlyPath/_&/" \
			-e "s/test_deployedMode/_&/" \
			-i twisted/test/test_plugin.py
	fi
}

python_test() {
	# NOTE: on pypy a couple of failures (refcounting, version-checking) is
	# expected

	"${PYTHON}" setup.py build -b "build-${EPYTHON}" install --root="${T}/tests-${EPYTHON}" --no-compile || die "Installation of tests failed"

	pushd "${T}/tests-${EPYTHON}${EPREFIX}$(python_get_sitedir)" > /dev/null || die

	# Skip broken tests.
	sed -e "s/test_buildAllTarballs/_&/" -i twisted/python/test/test_release.py || die "sed failed"

	# http://twistedmatrix.com/trac/ticket/5375
	sed -e "/class ZshIntegrationTestCase/,/^$/d" -i twisted/scripts/test/test_scripts.py || die "sed failed"

	# tap2rpm is already skipped if rpm is not installed, but fails for me on a Gentoo box with it present.
	# I currently lack the cycles to track this failure down.
	rm twisted/scripts/test/test_tap2rpm.py

	# Prevent it from pulling in plugins from already installed twisted packages.
	rm -f twisted/plugins/__init__.py

	# An empty file doesn't work because the tests check for doc strings in all packages.
	echo "'''plugins stub'''" > twisted/plugins/__init__.py || die

	if ! PYTHONPATH="." "${T}/tests-${EPYTHON}${EPREFIX}/usr/bin/trial" twisted; then
		die "Tests failed with ${EPYTHON}"
	fi

	popd > /dev/null || die
}

python_install_all() {
	distutils-r1_python_install_all

	# Delete dropin.cache to avoid collisions.
	# dropin.cache is regenerated in pkg_postinst().
	rm -f "${D}$(python_get_sitedir)/twisted/plugins/dropin.cache"

	# Don't install index.xhtml page.
	doman doc/man/*.?
	insinto /usr/share/doc/${PF}
	doins -r $(find doc -mindepth 1 -maxdepth 1 -not -name man)

	newconfd "${FILESDIR}/twistd.conf" twistd
	newinitd "${FILESDIR}/twistd.init" twistd
}
