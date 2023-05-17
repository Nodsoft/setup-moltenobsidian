#!/bin/bash
#ver=> Ubuntu 20.04*

###@ MoltenObsidian setup script
###@ https://github.com/Nodsoft/setup-moltenobsidian
###@
###@ This script is intended to be used on a GitHub Actions runner 
###@ to setup the MoltenObsidian CLI tool.
###@ It is assumed that the runner already has the following installed:
###@ - dotnet

# Try/catch functions
function try()
{
    [[ $- = *e* ]]; SAVED_OPT_E=$?
    set +e
}

function catch()
{
    export ex_code=$?
    (( $SAVED_OPT_E )) && set +e
    return $ex_code
}

function throw()
{
    exit $1
}

version=null;

# Catch any errors
try
(
	# Get version if any (option: -v <version>)
	while getopts v: flag 
	do
		if [ $flag == "v" ]	
		then
			version=$OPTARG
		fi
	done

	# Install MoltenObsidian
	echo "Installing MoltenObsidian..."
	
	command="dotnet tool install -g Nodsoft.MoltenObsidian.Tool"
	if [ "$version" != null ]
	then
		command="$command --version $version"
	fi
	
	# Debug
	echo "::debug::Command: $command"

	$command
	
	echo "::group::MoltenObsidian installed successfully."
	echo "Installed version: $(moltenobsidian --version)"
	echo "::endgroup::"
)
catch || 
(
	# Okay, something went wrong.
	# Let's send an error back to the runner.
	
	echo "::error title=Failed to install MoltenObsidian::Error: $ex_code"
)