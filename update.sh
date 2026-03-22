#!/bin/bash
set -euxo pipefail

VOTEKEY=${1:-dz2026}

VolitveBASEURL="https://volitve.dvk-rs.si/${VOTEKEY}"
CURL="curl --progress-bar --fail --connect-timeout 300"
DIR="data/${VOTEKEY}"
mkdir -p "${DIR}"

$CURL "${VolitveBASEURL}/config/config.json"   | jq > ${DIR}/config.json
$CURL "${VolitveBASEURL}/data/obvestila.json"  | jq > ${DIR}/obvestila.json
$CURL "${VolitveBASEURL}/data/data.json"       | jq > ${DIR}/data.json
jq -r '(.slovenija.enote | map({st: .st, naziv: .naz} ))| (.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' ${DIR}/data.json > ${DIR}/enote.csv

#check ig VOTEKEY doesn't start with "referendum"
if [[ $VOTEKEY != referendum* ]]
then
    $CURL "${VolitveBASEURL}/data/liste.json"      | jq > ${DIR}/liste.json
    jq -r '(.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' ${DIR}/liste.json > ${DIR}/liste.csv
    # don't update candidates with censored data anymore:
    # $CURL "${VolitveBASEURL}/data/kandidati.json"  | jq > ${DIR}/kandidati.json
    # jq -r 'map({zap_st: .zap_st, st: .st, id: .id, ime: .ime, priimek: .pri, datum_rojstva: .dat_roj[0:10], poklic: .pokl, delo: .del , obcina: .obc , naselje: .nas , ulica: .ul , hisna_st: .hst, spol: .spol , ptt: .ptt , ptt_st: .ptt_st , enota: .enota, okraj_1: .okraji[0], okraj_2: .okraji[1] }) | (.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' ${DIR}/kandidati.json > ${DIR}/kandidati.csv
fi

$CURL "${VolitveBASEURL}/data/zgod_udel.json"  | jq > ${DIR}/zgod_udel.json

# Iz navodil medijem:
# https://www.dvk-rs.si/volitve-in-referendumi/drzavni-zbor-rs/volitve-drzavnega-zbora-rs/volitve-v-dz-2022/#accordion-1731-body-6
$CURL "${VolitveBASEURL}/data/udelezba.json"            | jq > ${DIR}/udelezba.json
$CURL "${VolitveBASEURL}/data/udelezba.csv"                  > ${DIR}/udelezba.csv
$CURL "${VolitveBASEURL}/data/rezultati.json"           | jq > ${DIR}/rezultati.json
$CURL "${VolitveBASEURL}/data/rezultati.csv"                 > ${DIR}/rezultati.csv
$CURL "${VolitveBASEURL}/data/izvoz.xlsx"                    > ${DIR}/izvoz.xlsx

if [[ $VOTEKEY != referendum* ]]
then
    $CURL "${VolitveBASEURL}/data/kandidati_rezultati.json" | jq > ${DIR}/kandidati_rezultati.json
    $CURL "${VolitveBASEURL}/data/mandati.csv"                   > ${DIR}/mandati.csv
fi

for VE in {1..8}
do
    VETEMP="0${VE}"
    VEPAD="${VETEMP: -2}" #pad left with 0s to max 2 chars
    for VO in {1..11}
    do
        VOTEMP="0${VO}"
        VOPAD="${VOTEMP: -2}"
        echo "Scraping VE:${VEPAD} VO:${VOPAD}..."
        $CURL "${VolitveBASEURL}/data/volisca_${VEPAD}_${VOPAD}.json" | jq > ${DIR}/volisca_${VEPAD}_${VOPAD}.json
    done
done


# BASEURL="https://www.dvk-rs.si/fileadmin/dvk_maps"
# mkdir -p dvk

# curl -s "${BASEURL}/notifications.json" | jq > dvk/notifications.json
# curl -s "${BASEURL}/settings.json"      | jq > dvk/settings.json

# # curl -s "${BASEURL}/volisca.csv.json"   | jq > dvk/volisca.csv.json
# # jq -r '(.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' dvk/volisca.csv.json > dvk/volisca.csv

# # curl -s "${BASEURL}/pg_volisca.csv.json"   | jq > dvk/pg_volisca.csv.json
# # jq -r '(.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' dvk/pg_volisca.csv.json > dvk/pg_volisca.csv

# RpeApiBaseURL="https://dvk-rpe.transmedia-design.me/api"
# mkdir -p dvk-rpe-api
# curl -s "${RpeApiBaseURL}/polling_stations/?cid=1"   | jq > dvk-rpe-api/volisca-redna.json
# jq -r '(.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' dvk-rpe-api/volisca-redna.json > dvk-rpe-api/volisca-redna.csv
# curl -s "${RpeApiBaseURL}/polling_stations/?cid=2"   | jq > dvk-rpe-api/volisca-predcasna.json
# jq -r '(.[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv' dvk-rpe-api/volisca-predcasna.json > dvk-rpe-api/volisca-predcasna.csv
