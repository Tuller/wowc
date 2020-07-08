#!/usr/bin/env bash

# wow.sh uses the bigwigs packager to generate a folder and copy it over to
# an existing wow directory

usage() {
	echo "Usage: wowc.sh -ABCP[-c client]" >&2
	echo "  -c client        Selects the wow client to publish to. Defaults to retail." >&2
}

declare -A WOW_CLIENTS

WOW_CLIENTS["retail"]="_retail_"
WOW_CLIENTS["classic"]="_classic_"
WOW_CLIENTS["ptr"]="_ptr_"
WOW_CLIENTS["beta"]="_beta_"
WOW_CLIENTS["alpha"]="_alpha_"
WOW_CLIENTS["classic-ptr"]="_classic_ptr_"
WOW_CLIENTS["classic-beta"]="_classic_beta_"
WOW_CLIENTS["classic-alpha"]="_classic_alpha_"

wow_client="retail"

# figure out what client to use from the command line options
OPTIND=1
while getopts "CPR:c:h?" opt; do
	case $opt in
	A)
		wow_client="alpha"
		;;
	B)
		wow_client="beta"
		;;			
	C)
		wow_client="classic"
		;;	
	P)
		wow_client="ptr"
		;;			
	c)
		# Sets the client to use
		echo $OPTARG

		if [ ! ${WOW_CLIENTS[$OPTARG]} ]; then
			echo "Invalid argument for option \"-c\" - \"$OPTARG\" is not a valid game client." >&2
			usage
			exit 1
		fi
		wow_client="$OPTARG"
		;;
	\?)
		if [ "$OPTARG" != "?" ] && [ "$OPTARG" != "h" ]; then
			echo "Unknown option \"-$OPTARG\"." >&2
		fi

		usage
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

# test to see if we're running classic
wow_classic=false
if [[ $wow_client == classic* ]]; then
	wow_classic=true
fi

echo "client = $wow_client"
echo "classic = $wow_classic"

# build the packager command
pkg_cmd=

# set a game version if we're building a classic release
if [[ $wow_classic ]]; then
	# if we have a .pkgmeta specific to a client, use that one
	if [ -f .pkgmeta-$wow_client ]; then
		pkg_cmd="wowpkg -dlz -g 1.13.5 -m .pkgmeta-$wow_client"
	else
		pkg_cmd="wowpkg -dlz -g 1.13.5"
	fi
else
	# if we have a .pkgmeta specific to a client, use that one
	if [ -f .pkgmeta-$wow_client ]; then
		pkg_cmd="wowpkg -dlz -m .pkgmeta-$wow_client"
	else
		pkg_cmd="wowpkg -dlz"
	fi
fi

echo "$pkg_cmd"
$pkg_cmd

# sync everything in ./release with a corresponding directory in the addons folder
wow_addons_path="$WOW_ROOT/${WOW_CLIENTS[$wow_client]}/Interface/AddOns"

for D in ./.release/*; do
	if [ -d "${D}" ]; then
		dir=$(basename ${D})

		if [[ $dir == \!* ]]; then
			echo "Skipping $dir - Directory name begins with a !"
		else
			echo "Copying $dir to $wow_addons_path"
			rsync -zrvh .release/$dir/ "$wow_addons_path/$dir" --delete
		fi
	fi
done

# remove the release folder if it exists
if [ -d ./.release ]; then
	rm -r ./.release
fi