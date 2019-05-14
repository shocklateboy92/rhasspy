#!/usr/bin/env bash
set -e

if [[ -z "$1" ]]; then
    echo "Directory required as first argument"
    exit 1
fi

DIR="$1"
download_dir="${DIR}/download"

if [[ "$2" = "--delete" ]]; then
    rm -rf "${download_dir}"
fi

mkdir -p "${download_dir}"

echo "Downloading German (de) profile (sphinx)"

#------------------------------------------------------------------------------
# Acoustic Model
#------------------------------------------------------------------------------

acoustic_url='https://github.com/synesthesiam/rhasspy-profiles/releases/download/v1.0-de/cmusphinx-de-voxforge-5.2.tar.gz'
acoustic_file="${download_dir}/cmusphinx-de-voxforge-5.2.tar.gz"
acoustic_output="${DIR}/acoustic_model"

if [[ ! -s "${acoustic_file}" ]]; then
    echo "Downloading acoustic model (${acoustic_url})"
    curl -sSfL -o "${acoustic_file}" "${acoustic_url}"
fi

echo "Extracting acoustic model (${acoustic_file})"
rm -rf "${acoustic_output}"
tar -C "${DIR}" -xf "${acoustic_file}" "cmusphinx-cont-voxforge-de-r20171217/model_parameters/voxforge.cd_cont_6000/" && mv "${DIR}/cmusphinx-cont-voxforge-de-r20171217/model_parameters/voxforge.cd_cont_6000" "${acoustic_output}" && rm -rf "${DIR}/cmusphinx-cont-voxforge-de-r20171217"

#------------------------------------------------------------------------------
# G2P
#------------------------------------------------------------------------------

g2p_url='https://github.com/synesthesiam/rhasspy-profiles/releases/download/v1.0-de/de-g2p.tar.gz'
g2p_file="${download_dir}/de-g2p.tar.gz"
g2p_output="${DIR}/g2p.fst"

if [[ ! -s "${g2p_file}" ]]; then
    echo "Downloading g2p model (${g2p_url})"
    curl -sSfL -o "${g2p_file}" "${g2p_url}"
fi

echo "Extracting g2p model (${g2p_file})"
tar --to-stdout -xzf "${g2p_file}" 'g2p.fst' > "${g2p_output}"

#------------------------------------------------------------------------------
# Dictionary
#------------------------------------------------------------------------------

dict_output="${DIR}/base_dictionary.txt"
echo "Extracting dictionary (${acoustic_file})"
tar --to-stdout -xf "${acoustic_file}" "cmusphinx-cont-voxforge-de-r20171217/etc/voxforge.dic" > "${dict_output}"

#------------------------------------------------------------------------------
# Language Model
#------------------------------------------------------------------------------

lm_url='https://github.com/synesthesiam/rhasspy-profiles/releases/download/v1.0-de/cmusphinx-voxforge-de.lm.gz'
lm_file="${download_dir}/cmusphinx-voxforge-de.lm.gz"
lm_output="${DIR}/base_language_model.txt"

if [[ ! -s "${lm_file}" ]]; then
    echo "Downloading language model (${lm_url})"
    curl -sSfL -o "${lm_file}" "${lm_url}"
fi

echo "Extracting language model (${lm_file})"
zcat "${lm_file}" > "${lm_output}"

#------------------------------------------------------------------------------
# Snowboy
#------------------------------------------------------------------------------

snowboy_models=("snowboy.umdl" "computer.umdl")
for model_name in "${snowboy_models[@]}"; do
    model_output="${DIR}/${model_name}"
    if [[ ! -s "${model_output}" ]]; then
        model_url="https://github.com/Kitt-AI/snowboy/raw/master/resources/models/${model_name}"
        echo "Downloading ${model_output} (${model_url})"
        curl -sSfL -o "${model_output}" "${model_url}"
    fi
done

#------------------------------------------------------------------------------
# Mycroft Precise
#------------------------------------------------------------------------------

precise_files=("hey-mycroft-2.pb" "hey-mycroft-2.pb.params")
for file_name in "${precise_files[@]}"; do
    file_output="${DIR}/${file_name}"
    if [[ ! -s "${file_output}" ]]; then
        file_url="https://github.com/MycroftAI/precise-data/raw/models/${file_name}"
        echo "Downloading ${file_output} (${file_url})"
        curl -sSfL -o "${file_output}" "${file_url}"
    fi
done
