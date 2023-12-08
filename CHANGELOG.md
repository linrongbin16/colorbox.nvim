# Changelog

## [1.9.2](https://github.com/linrongbin16/colorbox.nvim/compare/v1.9.1...v1.9.2) (2023-12-08)


### Performance Improvements

* **ci:** upload luarocks ([#77](https://github.com/linrongbin16/colorbox.nvim/issues/77)) ([b6c7f59](https://github.com/linrongbin16/colorbox.nvim/commit/b6c7f593a005c40c185fb36966d075c799e19239))

## [1.9.1](https://github.com/linrongbin16/colorbox.nvim/compare/v1.9.0...v1.9.1) (2023-12-07)


### Performance Improvements

* **install:** optimize log message ([#75](https://github.com/linrongbin16/colorbox.nvim/issues/75)) ([1ddde8c](https://github.com/linrongbin16/colorbox.nvim/commit/1ddde8c5ebfa4041952757e9d33da799ff039aa6))

## [1.9.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.8.0...v1.9.0) (2023-12-07)


### Features

* **policy:** add 'by filetype' policy ([#72](https://github.com/linrongbin16/colorbox.nvim/issues/72)) ([2910a20](https://github.com/linrongbin16/colorbox.nvim/commit/2910a203698851f50b2d9e5754978d7939d3769f))

## [1.8.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.7.1...v1.8.0) (2023-12-07)


### Features

* **policy:** add 'single' policy ([#70](https://github.com/linrongbin16/colorbox.nvim/issues/70)) ([da537b4](https://github.com/linrongbin16/colorbox.nvim/commit/da537b4aa5aa9f02692d815b4eddce15db2c65dc))


### Performance Improvements

* **collector:** improve colorschemes list ([#66](https://github.com/linrongbin16/colorbox.nvim/issues/66)) ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **colorschemes:** improve COLORSCHEMES list ([#71](https://github.com/linrongbin16/colorbox.nvim/issues/71)) ([5211c28](https://github.com/linrongbin16/colorbox.nvim/commit/5211c282596e37755908908f9e04146b947fc9d3))
* **config:** by default only enable 'primary' colors ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **policy:** remove 'name' from fixed interval policy ([#68](https://github.com/linrongbin16/colorbox.nvim/issues/68)) ([759d524](https://github.com/linrongbin16/colorbox.nvim/commit/759d524f2e244a2718836b0498a66391f0ab3a14))

## [1.7.1](https://github.com/linrongbin16/colorbox.nvim/compare/v1.7.0...v1.7.1) (2023-11-28)


### Bug Fixes

* **install:** fix NPE while installation ([#64](https://github.com/linrongbin16/colorbox.nvim/issues/64)) ([3aa8c2d](https://github.com/linrongbin16/colorbox.nvim/commit/3aa8c2d5fb9a412f643baddea4d0b3840d2092cb))

## [1.7.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.6.0...v1.7.0) (2023-11-24)


### Features

* **install:** support 'reinstall' on Windows ([#62](https://github.com/linrongbin16/colorbox.nvim/issues/62)) ([9f00c7b](https://github.com/linrongbin16/colorbox.nvim/commit/9f00c7ba8814b8d2d5b1a8000d068a949954a3f7))


### Bug Fixes

* **filter:** fix 'primary' filter ([91e89c9](https://github.com/linrongbin16/colorbox.nvim/commit/91e89c9c553c3df59e6ebf26bb1038450f883c30))

## [1.6.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.5.0...v1.6.0) (2023-11-24)


### Features

* **fixed interval:** support fixed interval timing and policy ([#59](https://github.com/linrongbin16/colorbox.nvim/issues/59)) ([f0fcd55](https://github.com/linrongbin16/colorbox.nvim/commit/f0fcd552d3b9d9142b101d070034f1f09008a28d))

## [1.5.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.4.0...v1.5.0) (2023-11-24)


### Features

* **controller:** provide `update` option ([#57](https://github.com/linrongbin16/colorbox.nvim/issues/57)) ([c6338ff](https://github.com/linrongbin16/colorbox.nvim/commit/c6338ff63452e78e6492a83da19e38e5646ce241))

## [1.4.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.3.1...v1.4.0) (2023-11-23)


### Features

* **command:** add `Colorbox` command and provide `reinstall` option ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* **install:** use `neovim` branch for `lifepillar/vim-solarized8` ([#52](https://github.com/linrongbin16/colorbox.nvim/issues/52)) ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))

## [1.3.1](https://github.com/linrongbin16/colorbox.nvim/compare/v1.3.0...v1.3.1) (2023-11-23)


### Performance Improvements

* **build:** async run to avoid blocking ([#46](https://github.com/linrongbin16/colorbox.nvim/issues/46)) ([814a927](https://github.com/linrongbin16/colorbox.nvim/commit/814a927a14669af4c8d5c86f22cf75488cf408ee))
* **build:** improve git submodules installation speed ([#50](https://github.com/linrongbin16/colorbox.nvim/issues/50)) ([18ce09e](https://github.com/linrongbin16/colorbox.nvim/commit/18ce09eb234a8788cdadcfd56ffff9818fceadb5))

## [1.3.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.2.0...v1.3.0) (2023-11-22)


### Features

* **policy:** add `reverse_order` policy ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))


### Performance Improvements

* **shuffle:** better bitwise xor for random integer ([#44](https://github.com/linrongbin16/colorbox.nvim/issues/44)) ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))

## [1.2.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.1.2...v1.2.0) (2023-11-22)


### Features

* **config:** add `cache_dir` option ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **policy:** play in order ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))


### Performance Improvements

* **install:** optimize install logs ([#41](https://github.com/linrongbin16/colorbox.nvim/issues/41)) ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))

## [1.1.2](https://github.com/linrongbin16/colorbox.nvim/compare/v1.1.1...v1.1.2) (2023-11-22)


### Performance Improvements

* **init:** improve speed via build index when initializing ([#37](https://github.com/linrongbin16/colorbox.nvim/issues/37)) ([8782111](https://github.com/linrongbin16/colorbox.nvim/commit/8782111bdfbe42412a3b3cf00852a9da79f99443))

## [1.1.1](https://github.com/linrongbin16/colorbox.nvim/compare/v1.1.0...v1.1.1) (2023-11-21)


### Performance Improvements

* **load:** improve loading data speed ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **refactor:** improve code structure ([#33](https://github.com/linrongbin16/colorbox.nvim/issues/33)) ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))

## [1.1.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.0.1...v1.1.0) (2023-11-21)


### Features

* **update:** auto-update ([#28](https://github.com/linrongbin16/colorbox.nvim/issues/28)) ([a730726](https://github.com/linrongbin16/colorbox.nvim/commit/a73072677d9ec24006818710531cd3bcc7200529))


### Performance Improvements

* **ci:** reduce to weekly run ([#30](https://github.com/linrongbin16/colorbox.nvim/issues/30)) ([f4f7603](https://github.com/linrongbin16/colorbox.nvim/commit/f4f7603285ad6a8df83d3312550bbf7ac3dbdda2))

## [1.0.1](https://github.com/linrongbin16/colorbox.nvim/compare/v1.0.0...v1.0.1) (2023-11-21)


### Bug Fixes

* **install:** fix NPE in first installation ([#24](https://github.com/linrongbin16/colorbox.nvim/issues/24)) ([2871108](https://github.com/linrongbin16/colorbox.nvim/commit/2871108ef8093da431df47eea57558c6144f862c))

## 1.0.0 (2023-11-21)


### Features

* **filter:** add 'primary' filter ([#21](https://github.com/linrongbin16/colorbox.nvim/issues/21)) ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* MPV done ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* update docs ([#19](https://github.com/linrongbin16/colorbox.nvim/issues/19)) ([0e7a564](https://github.com/linrongbin16/colorbox.nvim/commit/0e7a564ef92073a172356acadf183f8f6b7965df))
