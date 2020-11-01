#!/bin/bash

function download_model {
    ggID=$1
    model_name=$2
    ggURL='https://drive.google.com/uc?export=download'
    archive="${model_name}.tar.gz"

    echo "Downloading ${archive}"

    filename="$(curl -sc /tmp/gcokie "${ggURL}&id=${ggID}" | grep -o '="uc-name.*</span>' | sed 's/.*">//;s/<.a> .*//')"
    getcode="$(awk '/_warning_/ {print $NF}' /tmp/gcokie)"
    curl -Lb /tmp/gcokie "${ggURL}&confirm=${getcode}&id=${ggID}" -o "${archive}"

    echo "Unpacking ${archive} in models directory"
    target_dir="models/${model_name}"
    mkdir -p "${target_dir}"
    tar zxvf "${archive}" -C "${target_dir}"
}

download_model "1FvMpjTfumVaSfwTOdWbJfEYFgGSAs0CS" "qasrl_parser_elmo"
download_model "17PxJ7SXTsn28Sp032dZRjq_pcqDhn781" "qanom_parser_elmo"
echo "Done."

