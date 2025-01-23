#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2025 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail

stdout=$2

{
    dir="${TARGET}"
    mkdir -p "${dir}"
    touch "${dir}/LCOM5.csv"
    echo "repo,java_file,LCOM5" > "${dir}/LCOM5.csv"
    echo "kek,src/main/kek,42.000" >> "${dir}/LCOM5.csv"
    "${LOCAL}/steps/aggregation-functions/90-percentile.sh" "${dir}/LCOM5.csv" "${TARGET}/data/aggregation" "LCOM5"
    test -e "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv"
    percentile_value=$(cat "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv")
} > "${stdout}" 2>&1
echo "👍🏻 Single metric (LCOM5) 90th percentile calculated correctly"

{
    dir1="${TARGET}"
    mkdir -p "${dir1}"
    touch "${dir1}/LCOM5.csv"
    echo "repo,java_file,LCOM5" > "${dir1}/LCOM5.csv"
    echo "kek,src/main/kek,42.000" >> "${dir1}/LCOM5.csv"
    touch "${dir1}/NHD.csv"
    echo "repo,java_file,NHD" > "${dir1}/NHD.csv"
    echo "kek,src/main/kek,1000.000" >> "${dir1}/NHD.csv"
    "${LOCAL}/steps/aggregation-functions/90-percentile.sh" "${dir1}/LCOM5.csv" "${TARGET}/data/aggregation" "LCOM5"
    "${LOCAL}/steps/aggregation-functions/90-percentile.sh" "${dir1}/NHD.csv" "${TARGET}/data/aggregation" "NHD"
    test -e "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv"
    percentile_value_lcom5=$(cat "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv")
    test "$percentile_value_lcom5" = "42.000"
    test -e "${TARGET}/data/aggregation/NHD.90th_percentile.csv"
    percentile_value_nhd=$(cat "${TARGET}/data/aggregation/NHD.90th_percentile.csv")
    test "$percentile_value_nhd" = "1000.000"
} > "${stdout}" 2>&1
echo "👍🏻 Multiple metrics (LCOM5, NHD) aggregated correctly"
{
    dir="${TARGET}"
    mkdir -p "${dir}"
    touch "${dir}/Empty.java.m.LCOM5"
    echo "repo,java_file,LCOM5" > "${dir}/Empty.java.m.LCOM5"
    "${LOCAL}/steps/aggregation-functions/90-percentile.sh" "${dir}/Empty.java.m.LCOM5" "${TARGET}/data/aggregation" "LCOM5"
    test -e "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv"
    percentile_value=$(cat "${TARGET}/data/aggregation/LCOM5.90th_percentile.csv")
    test "$percentile_value" = "0.000"
} > "${stdout}" 2>&1
echo "👍🏻 Edge case with no data handled correctly"
