EAPI=6

DESCRIPTION="a media player aiming to be similar to AmaroK, but for GTK+"
HOMEPAGE="http://www.exaile.org/"

SRC_URI="https://github.com/exaile/exaile/archive/fca0d5e17ce0d06453bb89b886ab5d1c37034864.zip -> exaile-4.0.0_beta2.zip"

LICENSE="GPL-2 GPL-3"
SLOT="0"
KEYWORDS="amd64 ~x86 ~arm"
IUSE="moodbar"

RDEPEND="
	moodbar? ( media-sound/moodbar )"
DEPEND="
	${RDEPEND}
"

S=${WORKDIR}/exaile-fca0d5e17ce0d06453bb89b886ab5d1c37034864/

