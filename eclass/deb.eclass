# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/rpm.eclass,v 1.22 2011/12/27 17:55:12 fauli Exp $

# @ECLASS: deb.eclass
# @MAINTAINER:
# base-system@gentoo.org
# @AUTHOR:
# Author: Christoph Junghans <ottxor@gentoo.org>
# @BLURB: convenience class for extracting deb packages

case ${EAPI:-0} in
    3|4) ;;
    *) die "EAPI ${EAPI} unsupported (yet)."
esac

# @FUNCTION: deb_unpack
# @USAGE: <debs>
# @DESCRIPTION:
# Unpack the contents of the specified debs like the unpack() function and
# data.tar.* therein.
deb_unpack() {
    [[ $# -eq 0 ]] && set -- ${A}
    local x
    for x in "$@" ; do
        [[ ${x} = *.deb ]] || \
            die "${FUNCNAME[0]} only handles *.deb files, but ${x} given."

        echo ">>> Unpacking ${x} to ${PWD}"

        local srcdir
        if [[ ${x} == "./"* ]] ; then
            srcdir=""
        elif [[ ${x} == ${DISTDIR%/}/* ]] ; then
            die "Arguments to ${FUNCNAME[0]} cannot begin with \${DISTDIR}."
        elif [[ ${x} == "/"* ]] ; then
            die "Arguments to ${FUNCNAME[0]} cannot be absolute"
        else
            srcdir="${DISTDIR}/"
        fi
        [[ ! -s ${srcdir}${x} ]] && die "${x} does not exist"

        local out
        #see https://en.wikipedia.org/wiki/Ar_%28Unix%29 and bug #384147#c19
        {
            read #global header
            [[ $REPLY = "!<arch>" ]] || die "$x does not seem to be a deb archive"
            local filename timestamp uid gid mode size magic
            while read filename timestamp uid gid mode size magic; do
                # do nothing for empty lines
                [[ -n $filename && -n $size ]] || continue
                if [[ $filename = data* ]]; then
                    [[ -n $out ]] && die "$x has two data archives"
                    out="${x##*/}"
                    out="${out%.deb}${filename#data}"
                    head -c "${size}" > "${out}"
                    echo ">>> Write content of $filename to $out"
                else
                    # trash non data files
                    head -c "${size}" > /dev/null
                fi
            done
         } < "${srcdir}$x"

         [[ -f $out ]] || die "No data archive was extracted from $x"
         unpack ./"${out}"
    done
}

# @FUNCTION: deb_src_unpack
# @DESCRIPTION:
# Automatically unpack all archives in ${A} including debs.
deb_src_unpack() {
    local a
    for a in ${A} ; do
        case ${a} in
        *.deb) deb_unpack "${a}" ;;
        *)     unpack "${a}" ;;
        esac
    done
}

EXPORT_FUNCTIONS src_unpack
