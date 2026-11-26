# device-pollingrate-tester

![test](https://github.com/ReBot-dev/device-pollingrate-tester/actions/workflows/test.yml/badge.svg)

**[日本語](#日本語)** | **[English](#english)**

---

## 日本語

デバイスがパソコンに報告を送った時刻を標準入力から読み、隣り合う時刻の差(報告の間隔、秒)を1行ずつ標準出力に出すコマンド `dpt` です。
マウスなどのポーリングレート(1秒あたりの報告回数)を調べるのに使えます。

### 対象のデバイス

動かしている間、報告を送り続けるデバイスに使えます。

- 対応: マウス(動かしている間)、ジャイロ付きのゲームパッド、ペンタブレット(ペンを浮かせている間)
- 非対応: 一般的なキーボード(キーを押したとき・離したときにしか報告しないため)

### インストール

```bash
$ git clone https://github.com/ReBot-dev/device-pollingrate-tester.git
$ cd device-pollingrate-tester
```

### 入力と出力

- 入力: 1行に1つ、時刻を秒で書いた数字
- 出力: 隣り合う時刻の差(秒)。N 行入力すると N−1 行出力します

```bash
$ seq 0 0.25 1 | ./dpt
0.25
0.25
0.25
0.25
```

### マウスのポーリングレートを測る

[evtest](https://cgit.freedesktop.org/evtest/) でデバイスの報告を記録し、報告1回ごとに1つ出る `SYN_REPORT` の行から時刻を取り出して `dpt` に渡します。

0. evtest をインストールする

   ```bash
   $ sudo apt install evtest
   ```

1. デバイスの番号を調べる(一覧が出たら Ctrl+C で終了)

   ```bash
   $ sudo evtest
   ```

2. 記録する(`N` は手順1で調べた番号)。マウスを動かし続け、数秒たったら Ctrl+C で止める

   ```bash
   $ sudo evtest /dev/input/eventN > mouse.log
   ```

3. 間隔を出す

   ```bash
   $ grep SYN_REPORT mouse.log | awk '{print $3}' | tr -d , | ./dpt
   0.0009999275207519531
   0.0010001659393310547
   ```

   間隔の逆数がポーリングレート(Hz)です。

   ```bash
   $ grep SYN_REPORT mouse.log | awk '{print $3}' | tr -d , | ./dpt | awk '{print 1/$1}'
   1000.07
   999.834
   ```

注意:

- 大きな時刻(1970年からの秒数など)を扱うため、出力には 1μ秒より小さい誤差が出ます
- マウスを止めている間は報告が来ないため、その部分は大きな間隔として出力されます

### 終了ステータス

| 値 | 意味 |
|---|---|
| 0 | 正常終了(入力が1行だけのときは何も出力せずに終了) |
| 3 | 数字でない行(空行を含む)があった |
| 4 | 入力が空だった |

エラーのメッセージは標準エラー出力に出します。

### 必要なソフトウェア

- Python
  - テスト済みバージョン: 3.10〜3.14

### テスト環境

- Ubuntu 26.04

### ライセンス

- このソフトウェアパッケージは、3条項 BSD ライセンスの下、再頒布および使用が許可されます。
- © 2026 ReBot

---

## English

`dpt` reads the times at which a device sent reports to the computer from standard input, and writes the differences between neighboring times (the report intervals, in seconds) to standard output, one per line.
It can be used to check the polling rate (reports per second) of a mouse or other device.

### Supported devices

It works with devices that keep sending reports while in use.

- Works: mice (while moving), gamepads with a gyro, pen tablets (while the pen is hovering)
- Does not work: typical keyboards (they report only when a key is pressed or released)

### Installation

```bash
$ git clone https://github.com/ReBot-dev/device-pollingrate-tester.git
$ cd device-pollingrate-tester
```

### Input and output

- Input: one time per line, in seconds
- Output: the difference between neighboring times, in seconds. N input lines give N−1 output lines

```bash
$ seq 0 0.25 1 | ./dpt
0.25
0.25
0.25
0.25
```

### Measuring the polling rate of a mouse

Record the device reports with [evtest](https://cgit.freedesktop.org/evtest/), take the time from each `SYN_REPORT` line (one per report), and pass it to `dpt`.

0. Install evtest

   ```bash
   $ sudo apt install evtest
   ```

1. Find the device number (press Ctrl+C after the list is shown)

   ```bash
   $ sudo evtest
   ```

2. Record (`N` is the number from step 1). Keep moving the mouse, and press Ctrl+C after a few seconds

   ```bash
   $ sudo evtest /dev/input/eventN > mouse.log
   ```

3. Get the intervals

   ```bash
   $ grep SYN_REPORT mouse.log | awk '{print $3}' | tr -d , | ./dpt
   0.0009999275207519531
   0.0010001659393310547
   ```

   The polling rate (Hz) is the inverse of the interval.

   ```bash
   $ grep SYN_REPORT mouse.log | awk '{print $3}' | tr -d , | ./dpt | awk '{print 1/$1}'
   1000.07
   999.834
   ```

Notes:

- Because the times are large numbers (such as seconds since 1970), the output has an error smaller than 1 μs
- No reports arrive while the mouse is not moving, so those parts appear as large intervals

### Exit status

| Value | Meaning |
|---|---|
| 0 | Success (with only one input line, nothing is printed) |
| 3 | A line that is not a number (including an empty line) was found |
| 4 | The input was empty |

Error messages are written to standard error.

### Requirements

- Python
  - Tested versions: 3.10 to 3.14

### Tested on

- Ubuntu 26.04

### License

- This software package is licensed under the BSD 3-Clause License, and redistribution and use are permitted under its terms.
- © 2026 ReBot
