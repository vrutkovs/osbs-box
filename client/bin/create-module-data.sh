#!/bin/bash
#make /mnt/koji structure
# Add kojibuilder to createrepo channel
set -e

WORKDIR=/mnt/koji/modules
PDC_URL=http://pdc/rest_api/v1

BUILD_GROUP="bash bzip2 coreutils cpio diffutils fedora-release findutils gawk gcc gcc-c++ gzip info make patch redhat-rpm-config rpm-build sed shadow-utils tar unzip util-linux which xz"
SRPM_BUILD_GROUP="bash fedora-release fedpkg-minimal gnupg2 redhat-rpm-config rpm-build shadow-utils"

info() {
    echo -en "\e[1m"
    echo -n "$@"
    echo -e "\e[0m"
}

tag_exists() {
    tag=$1
    koji list-tags $tag | grep $tag > /dev/null
}

pdc_token() {
    curl -s --negotiate -H 'Accept: application/json' --basic --user admin:mypassword $PDC_URL/auth/token/obtain/   | python -c 'import json, sys; print json.load(sys.stdin)["token"]'
}

post_module_to_pdc() {
    module=$1
    token=$2

    module_json=$WORKDIR/$module/$module.json
    variant_uid=$(python -c 'import json, sys; f = open(sys.argv[1], "r"); print json.load(f)["variant_uid"]' $module_json)

    count=$(curl -s -H 'Accept: application/json' "$PDC_URL/unreleasedvariants/?variant_uid=$variant_uid" | python -c 'import json, sys; print json.load(sys.stdin)["count"]')
    if [ "$count" == 0 ] ; then
	echo -n "Uploading $variant_uid to PDC "
	curl -s -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Token $token" --data "@$module_json" $PDC_URL/unreleasedvariants/ > /dev/null
	echo "done"
    else
	echo "$variant_id  already found in PDC"
    fi
}

make_module_tag() {
    tag=$1
    info "Creating tag $tag"

    koji add-tag $tag
    koji add-tag --parent=$tag --arches "x86_64" $tag-build
    if [ $# -gt 1 ] ; then
	koji add-tag-inheritance --priority=2 $tag-build $2

	koji add-group $tag build
	koji add-group-pkg $tag build $BUILD_GROUP flatpak-rpm-macros flatpak-runtime-config

	koji add-group $tag srpm-build
	koji add-group-pkg $tag srpm-build $SRPM_BUILD_GROUP flatpak-rpm-macros flatpak-runtime-config
    fi
    koji add-tag-inheritance --priority=10 $tag-build bootstrap

    koji edit-tag $tag-build -x mock.package_manager=dnf
    koji edit-tag $tag-build -x mock.new_chroot=0

    koji add-target $tag $tag-build

    koji regen-repo $tag-build
}

if ! tag_exists bootstrap ; then
    info "Creating bootstrap tag"

    koji add-tag bootstrap
    koji add-external-repo -t bootstrap bootstrap-external-repo https://kojipkgs.fedoraproject.org/repos/f27-build/latest/\$arch/

    koji add-group bootstrap build
    koji add-group-pkg bootstrap build $BUILD_GROUP

    koji add-group bootstrap srpm-build
    koji add-group-pkg bootstrap srpm-build $SRPM_BUILD_GROUP
fi

if ! tag_exists gnome-runtime-f27 ; then
    make_module_tag gnome-runtime-f27
fi

token=$(pdc_token)

fake-module-build -w $WORKDIR  -g https://github.com/vrutkovs/gnome-runtime-f27 -b master gnome-runtime-f27
post_module_to_pdc gnome-runtime-f27 $token

if ! tag_exists module-eog-f27 ; then
    make_module_tag module-eog-f27 gnome-runtime-f27
fi

fake-module-build -w $WORKDIR  -g https://github.com/vrutkovs/module-eog-f27 -b master module-eog-f27
post_module_to_pdc module-eog-f27 $token
