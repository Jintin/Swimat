# Swimat

[![Build Status](https://travis-ci.org/Jintin/Swimat.svg?branch=master)](https://travis-ci.org/Jintin/Swimat)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/e3a2fb6a6ba34b11836d58cee0668fb9)](https://www.codacy.com/app/Jintin/Swimat?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Jintin/Swimat&amp;utm_campaign=Badge_Grade)
[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/matteocrippa/awesome-swift)

[![github](https://img.shields.io/github/release/Jintin/Swimat.svg)](https://github.com/Jintin/Swimat/releases/latest)
[![homebrew-cask](https://img.shields.io/homebrew/v/swimat.svg)](https://caskroom.github.io/)

Swimat is an Xcode plug-in to format your Swift code.

## Preview

![](./README/preview.gif)

## Installation

There are three way to install.

1. Install via [homebrew-cask](https://caskroom.github.io/)

  ```bash
  # Homebrew previous version
  brew cask install swimat
  ```
  ```bash
  # Homebrew latest version
  brew install --cask swimat
  ```

2. Download the App directly.<br>
  <https://github.com/Jintin/Swimat/releases/download/v1.6.2/Swimat.zip>

3. Clone and archive to Mac App by yourself.

## Usage

**After installation, you should open the `Swimat.app` once to make the functionality works.**

In the Xcode menu click **[Editor] -> [Swimat] -> [Format]** then the current active file will reformat.

You can also create a hot-key in **[Xcode] -> [Preferences..] -> [Key Bindings]**, if you don't have any prefernce you can set as <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>L</kbd>.

## TroubleShooting

Check [System Preferences] -> [Extensions] -> [Xcode Source Editor] -> [Swimat] is checked. ![](./README/setting.png)

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/Jintin/Swimat>.

## License

The module is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
