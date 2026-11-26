#!/bin/bash
# SPDX-FileCopyrightText: 2026 ReBot rebot_dev@rebotlab.net
# SPDX-License-Identifier: BSD-3-Clause

ng () {
    echo ${1}行目のテスト失敗
    res=1
}

res=0

### 正常な入力 ###
# 2進数で割り切れる値を使い、floatの誤差が出ないようにする
out=$(printf "0.5\n1.0\n1.75\n" | ./dpt)
[ "$?" = 0 ] || ng "$LINENO"
[ "${out}" = "0.5
0.75" ] || ng "$LINENO"

# 1行だけでは差が計算できないので、何も出さずに正常終了
out=$(echo 5 | ./dpt)
[ "$?" = 0 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

### 異常な入力 ###
# 1行目が数字でない
out=$(printf "abc\n1\n" | ./dpt)
[ "$?" = 3 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

# 2行目以降が数字でない
out=$(printf "1\nabc\n2\n" | ./dpt)
[ "$?" = 3 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

# 途中に空行がある
out=$(printf "1\n\n2\n" | ./dpt)
[ "$?" = 3 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

# 何も入力しない
out=$(printf "" | ./dpt)
[ "$?" = 4 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

[ "${res}" = 0 ] && echo OK
exit $res
