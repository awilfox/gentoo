# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_4} )

inherit distutils-r1

MY_PN=ConfigArgParse
MY_P=${MY_PN}-${PV}

DESCRIPTION="A drop-in replacement for argparse that adds support for config files and/or environment variables"
HOMEPAGE="https://github.com/zorro3/ConfigArgParse https://pypi.python.org/pypi/ConfigArgParse"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

S=${WORKDIR}/${MY_P}
