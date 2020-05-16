#!/bin/bash

this=$(basename ${BASH_SOURCE[0]})
thisdir=$(dirname ${BASH_SOURCE[0]})
source "${thisdir}/constants.sh"
source "${thisdir}/os.sh"

use_stdin="${use_stdin:-"true"}"
use_stdout="${use_stdout:-"false"}"
use_pushpop="${use_pushpop:-"true"}"
use_python="${use_python:-"false"}"
use_envpath="${use_envpath:-"false"}"
use_exitstat="${use_exitstat:-"true"}"
use_localoutdir="${use_localoutdir:-"false"}"

dirty="false"
nobuild="false"
nodiff="false"
for arg in "$@" ; do
	#echo $arg

	if [[ "$arg" == "--dirty" || "$arg" == "-d" ]] ; then
		dirty="true"

	elif [[ "$arg" == "--no-build" ]] ; then
		nobuild="true"

	elif [[ "$arg" == "--no-diff" ]] ; then
		nodiff="true"

	else
		echo "$this:  warning:  unknown cmd argument '$arg'"
		echo
	fi

done

if [[ "$use_python" != "true" && "$nobuild" != "true" ]]; then

	# No CMake for interpreted python

	export use_defaultgen

	if [[ "$dirty" != "true" ]]; then
		chmod +x "${thisdir}/clean.sh"
		"${thisdir}/clean.sh"
	fi

	chmod +x "${thisdir}/build.sh"
	"${thisdir}/build.sh"
	if [[ "$?" != "0" ]]; then
		echo "$this:  error:  cannot build"
		exit -1
	fi

fi

pwd=$(pwd)

if [[ "$use_python" == "true" ]]; then

	if [[ $machine == "Linux" || $machine == "Mac" ]]; then
		python="python3"
	else
		python="python"
	fi
	exe="$python $pwd/$exebase.py"

else

	if [[ "$use_envpath" == "true" ]]; then
		exe="$exebase"
	else

		if [[ $machine == "Linux" || $machine == "Mac" ]]; then
			exe="$pwd/$build/$exebase"
		else

			if [[ "$use_defaultgen" == "true" ]]; then
				exe="$pwd/$build/Release/$exebase.exe"
			else
				exe="$pwd/$build/$exebase.exe"
			fi

		fi

		if [[ ! -e "$exe" ]]; then
			echo "$this:  error:  executable \"$exe\" does not exist"
			exit -2

		fi
	fi
fi

echo "==============================================================================="
echo ""
echo "$this:  running tests with \"${exebase}\" ..."
echo ""

nfail=0
ntotal=0
nfailframes=0
ntotalframes=0
failedtests=()

for i in ${inputs}; do

	d=$(dirname "$i")
	ib=$(basename $i)
	inputext=${ib##*.}

	# Leave outputext outside of quotes as it may contain a glob which needs to
	# be expanded
	outputs=()
	if [[ "${#frames[@]}" == "0" ]]; then
		# No numbered frames, just a single output
		outputs+=( "${outdir}/${ib%.${inputext}}." )
	else
		for frame in "${frames[@]}"; do
			# This makes an assumption about where the frame number is in the
			# filename and how it is delimited.
			outputs+=( "${outdir}/${ib%.${inputext}}_${frame}." )
		done
	fi

	#echo "i   = $i"
	#echo "ib  = $ib"
	#echo "d   = $d"
	#echo ""

	if [[ "$use_localoutdir" != "true" && "$outputext" != "" ]]; then
		for output in "${outputs[@]}"${outputext}; do
			rm "${output}"
		done
	fi

	if [[ "$use_pushpop" == "true" ]]; then
		pushd $d
		il=$ib
	else
		il=$i
	fi

	if [[ "$use_localoutdir" == "true" && "$outputext" != "" ]]; then
		for output in "${outputs[@]}"${outputext}; do
			rm "${output}"
		done
	fi

	ntotal=$((ntotal + 1))
	failed="false"

	if [[ "$use_stdout" == "true" ]]; then

		if [[ "$use_stdin" == "true" ]]; then
			${exe} < "$il" > "${outputs[0]}"${outputext}
		else
			${exe} "$il" > "${outputs[0]}"${outputext}
		fi

	else

		if [[ "$use_stdin" == "true" ]]; then
			${exe} < "$il"
		else
			${exe} "$il"
		fi

	fi

	if [[ "$?" != "0" && "$use_exitstat" == "true" ]]; then
		failed="true"
		echo "$this:  error:  cannot run test $i"
	fi

	if [[ "$use_pushpop" == "true" && "$use_localoutdir" != "true" ]]; then
		popd
	fi

	if [[ "$failed" != "true" && "$nodiff" != "true" ]]; then
		for output in "${outputs[@]}"; do
			ntotalframes=$((ntotalframes + 1))

			diff -w "${expectedoutdir}/$(basename "${output}")"${outputext} "${output}"${outputext} > /dev/null
			diffout=$?
			if [[ "$diffout" == "1" ]]; then
				nfailframes=$((nfailframes + 1))
				failed="true"
				echo "$this:  error:  difference in ${output}${outputext}"
			elif [[ "$diffout" != "0" ]]; then
				nfailframes=$((nfailframes + 1))
				failed="true"
				echo "$this:  error:  cannot run diff in ${output}${outputext}"
			fi

		done
	fi

	if [[ "$use_pushpop" == "true" && "$use_localoutdir" == "true" ]]; then
		popd
	fi

	if [[ "$failed" == "true" ]]; then
		failedtests+=("$i")
		nfail=$((nfail + 1))
	fi

done

echo ""
echo "==============================================================================="
echo ""

echo "$this:  total tested frames     = $ntotalframes"
echo "$this:  total number of tests   = $ntotal"
echo "$this:  number of failed frames = $nfailframes"
echo "$this:  number of failed tests  = $nfail"
echo "$this:  done!"
echo ""

if [[ "$nfail" != "0" ]]; then
	echo "$this:  failed test(s):"
	echo "["
	for ftest in ${failedtests[@]} ; do
		echo "	$ftest"
	done
	echo "]"
	echo ""
	echo "$this:  error:  not all tests passed"
fi

# If a whole test fails to run, it won't count towards any failed frames
exit $nfail

