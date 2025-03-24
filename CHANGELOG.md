# Changelog

## [3.2.0](https://github.com/linrongbin16/colorbox.nvim/compare/v3.1.1...v3.2.0) (2025-03-24)


### Features

* **data:** give data change info ([#256](https://github.com/linrongbin16/colorbox.nvim/issues/256)) ([7eccdda](https://github.com/linrongbin16/colorbox.nvim/commit/7eccddae01c587c7586cecdea4651c2b5ab288ba))


### Bug Fixes

* **collect:** fix collector dedup logic ([bdfbd39](https://github.com/linrongbin16/colorbox.nvim/commit/bdfbd39f740d19148df1599684f9b72ef072830b))
* **data:** fix conflict data ([#258](https://github.com/linrongbin16/colorbox.nvim/issues/258)) ([4166c9e](https://github.com/linrongbin16/colorbox.nvim/commit/4166c9ec5cfb8f04f8f5245820de149146fc2774))
* **test:** fix unit tests ([#259](https://github.com/linrongbin16/colorbox.nvim/issues/259)) ([91bc5a9](https://github.com/linrongbin16/colorbox.nvim/commit/91bc5a936b9e581251b80154a3177804d7e667a6))

## [3.1.1](https://github.com/linrongbin16/colorbox.nvim/compare/v3.1.0...v3.1.1) (2025-02-02)


### Bug Fixes

* **async:** migrate to new "async" module ([#250](https://github.com/linrongbin16/colorbox.nvim/issues/250)) ([364992b](https://github.com/linrongbin16/colorbox.nvim/commit/364992b3771a6bc7af10a82dd9c5067c1e9e8824))

## [3.1.0](https://github.com/linrongbin16/colorbox.nvim/compare/v3.0.0...v3.1.0) (2024-06-13)


### Features

* Add shuffle command to change color randomly ([#239](https://github.com/linrongbin16/colorbox.nvim/issues/239)) ([3ad6453](https://github.com/linrongbin16/colorbox.nvim/commit/3ad645317ea624fb198fdd3764cc0ecc864778d2))

## [3.0.0](https://github.com/linrongbin16/colorbox.nvim/compare/v2.1.2...v3.0.0) (2024-06-04)


### ⚠ BREAKING CHANGES

* **configs:** set default filter to 'primary' for simplicity ([#237](https://github.com/linrongbin16/colorbox.nvim/issues/237))
* **command:** remove `reinstall` and `clean` sub commands ([#235](https://github.com/linrongbin16/colorbox.nvim/issues/235))

### Features

* **hook:** add 'post_hook' function hooks ([#238](https://github.com/linrongbin16/colorbox.nvim/issues/238)) ([9f91613](https://github.com/linrongbin16/colorbox.nvim/commit/9f9161338f79b827d3f15ad6b915eb4ffe51e6c1))


### Bug Fixes

* **policy:** correctly save track on loading colorscheme ([#235](https://github.com/linrongbin16/colorbox.nvim/issues/235)) ([c614017](https://github.com/linrongbin16/colorbox.nvim/commit/c61401747ac1576f7b0dbb9191544b8bbe544a2c))


### Code Refactoring

* **command:** remove `reinstall` and `clean` sub commands ([#235](https://github.com/linrongbin16/colorbox.nvim/issues/235)) ([c614017](https://github.com/linrongbin16/colorbox.nvim/commit/c61401747ac1576f7b0dbb9191544b8bbe544a2c))
* **configs:** set default filter to 'primary' for simplicity ([#237](https://github.com/linrongbin16/colorbox.nvim/issues/237)) ([a93736b](https://github.com/linrongbin16/colorbox.nvim/commit/a93736bb7c0e7d2886c3cb56fe9337fd49719a00))

## [2.1.2](https://github.com/linrongbin16/colorbox.nvim/compare/v2.1.1...v2.1.2) (2024-05-13)


### Bug Fixes

* **collector:** fix VCS ([#230](https://github.com/linrongbin16/colorbox.nvim/issues/230)) ([4769096](https://github.com/linrongbin16/colorbox.nvim/commit/4769096de361ada02b4d1d8f9f415046048c1325))

## [2.1.1](https://github.com/linrongbin16/colorbox.nvim/compare/v2.1.0...v2.1.1) (2024-05-06)


### Bug Fixes

* **install:** fix git submodules installation ([#227](https://github.com/linrongbin16/colorbox.nvim/issues/227)) ([8a79075](https://github.com/linrongbin16/colorbox.nvim/commit/8a79075402a68fad20009bb0d42ddb43dd81dc51))

## [2.1.0](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.17...v2.1.0) (2024-04-01)


### Features

* colorize info panel ([#224](https://github.com/linrongbin16/colorbox.nvim/issues/224)) ([24e690c](https://github.com/linrongbin16/colorbox.nvim/commit/24e690c54674b9715cce0368978e4f793d04d451))

## [2.0.17](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.16...v2.0.17) (2024-04-01)


### Performance Improvements

* directly generate lua table as db ([#220](https://github.com/linrongbin16/colorbox.nvim/issues/220)) ([9e2fc78](https://github.com/linrongbin16/colorbox.nvim/commit/9e2fc78e3bb835dfc69e9c37aa2fd03fab9bec78))

## [2.0.16](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.15...v2.0.16) (2024-03-27)


### Performance Improvements

* reduce db size ([#217](https://github.com/linrongbin16/colorbox.nvim/issues/217)) ([0035bf1](https://github.com/linrongbin16/colorbox.nvim/commit/0035bf1da01bddd0ca6fccafdcc193a57003c20d))
* set stars &gt;= 500 ([#219](https://github.com/linrongbin16/colorbox.nvim/issues/219)) ([6078fad](https://github.com/linrongbin16/colorbox.nvim/commit/6078fad32ce8465642cd274e3af0114dd7c842d1))

## [2.0.15](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.14...v2.0.15) (2024-03-20)


### Bug Fixes

* **collector:** remove 'RRethy/nvim-base16' from blacklist ([#214](https://github.com/linrongbin16/colorbox.nvim/issues/214)) ([1c23e24](https://github.com/linrongbin16/colorbox.nvim/commit/1c23e2481d5174fff071d31c165eb939ff714425))

## [2.0.14](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.13...v2.0.14) (2024-03-04)


### Bug Fixes

* **collector:** fix fetch exception during awesome-neovim ([#212](https://github.com/linrongbin16/colorbox.nvim/issues/212)) ([f952a14](https://github.com/linrongbin16/colorbox.nvim/commit/f952a144bce4b189d28f764dde8c16d544f91da2))

## [2.0.13](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.12...v2.0.13) (2024-03-01)


### Bug Fixes

* **loader:** don't run command in ColorSchemePre ([#209](https://github.com/linrongbin16/colorbox.nvim/issues/209)) ([0b90486](https://github.com/linrongbin16/colorbox.nvim/commit/0b9048698fc7b1105bfc5cacc84f261612d48185))

## [2.0.12](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.11...v2.0.12) (2024-02-29)


### Bug Fixes

* **loader:** check pack exists before apply color ([#207](https://github.com/linrongbin16/colorbox.nvim/issues/207)) ([8e504ca](https://github.com/linrongbin16/colorbox.nvim/commit/8e504caf9bc16d457539eaa32ecf52181fd39a04))
* **update:** fix missing 'update' api ([#205](https://github.com/linrongbin16/colorbox.nvim/issues/205)) ([42f896d](https://github.com/linrongbin16/colorbox.nvim/commit/42f896d18d1353bbe982acb9967d578362c4210f))

## [2.0.11](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.10...v2.0.11) (2024-02-29)


### Performance Improvements

* **startup:** improve rendering on nvim start ([#202](https://github.com/linrongbin16/colorbox.nvim/issues/202)) ([86ccc6e](https://github.com/linrongbin16/colorbox.nvim/commit/86ccc6e4b6e8a2fdfd89cf779bb96fb4c7380366))

## [2.0.10](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.9...v2.0.10) (2024-02-29)


### Bug Fixes

* **pack:** fix lua module/autoload not found by 'vim.schedule' ([#199](https://github.com/linrongbin16/colorbox.nvim/issues/199)) ([ce0cd6d](https://github.com/linrongbin16/colorbox.nvim/commit/ce0cd6d54318ffecfda3567af0d65afa368127d3))

## [2.0.9](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.8...v2.0.9) (2024-02-28)


### Performance Improvements

* **startup:** reduce startup time ([#196](https://github.com/linrongbin16/colorbox.nvim/issues/196)) ([737d5b1](https://github.com/linrongbin16/colorbox.nvim/commit/737d5b1181264a51c56f5e0776154bca14d945ea))

## [2.0.8](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.7...v2.0.8) (2024-02-26)


### Bug Fixes

* **collector:** fix duplicate color detect ([#189](https://github.com/linrongbin16/colorbox.nvim/issues/189)) ([c32ff65](https://github.com/linrongbin16/colorbox.nvim/commit/c32ff65df108c9923da36446b12502640173f19d))

## [2.0.7](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.6...v2.0.7) (2024-02-14)


### Bug Fixes

* fix bad colorscheme name in 'ColorScheme' event ([#186](https://github.com/linrongbin16/colorbox.nvim/issues/186)) ([1045168](https://github.com/linrongbin16/colorbox.nvim/commit/1045168d5ff103725aa37a7ed1d2884b89f73476))

## [2.0.6](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.5...v2.0.6) (2024-02-09)


### Bug Fixes

* **pack:** add plugin 'autoload' to rtp ([#184](https://github.com/linrongbin16/colorbox.nvim/issues/184)) ([b5f1ca3](https://github.com/linrongbin16/colorbox.nvim/commit/b5f1ca379058ce1bd5cfa430eb651e4a3002d800))

## [2.0.5](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.4...v2.0.5) (2024-02-05)


### Bug Fixes

* **timing:** remove 'UIEnter' from on nvim start ([#182](https://github.com/linrongbin16/colorbox.nvim/issues/182)) ([187cc48](https://github.com/linrongbin16/colorbox.nvim/commit/187cc488adbca13d1b4510bbb365f4ae2eab5c69))

## [2.0.4](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.3...v2.0.4) (2024-02-04)


### Bug Fixes

* **filetype policy:** listen to more events for correctly timely trigger ([#180](https://github.com/linrongbin16/colorbox.nvim/issues/180)) ([fefc64d](https://github.com/linrongbin16/colorbox.nvim/commit/fefc64d558d13ded814edf5499d5b4316738860b))


### Performance Improvements

* **filetype policy:** add 'empty' option for empty filetype ([#180](https://github.com/linrongbin16/colorbox.nvim/issues/180)) ([fefc64d](https://github.com/linrongbin16/colorbox.nvim/commit/fefc64d558d13ded814edf5499d5b4316738860b))
* **filetype policy:** make 'fallback' optional ([#180](https://github.com/linrongbin16/colorbox.nvim/issues/180)) ([fefc64d](https://github.com/linrongbin16/colorbox.nvim/commit/fefc64d558d13ded814edf5499d5b4316738860b))

## [2.0.3](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.2...v2.0.3) (2024-01-31)


### Bug Fixes

* deepcopy exception in ColorSchemePre ([#176](https://github.com/linrongbin16/colorbox.nvim/issues/176)) ([2e18e51](https://github.com/linrongbin16/colorbox.nvim/commit/2e18e514a467da265a714583a5ce3cd48780e5eb))

## [2.0.2](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.1...v2.0.2) (2024-01-24)


### Bug Fixes

* **install:** move 'db.json' to autoload to fix luarocks package ([#173](https://github.com/linrongbin16/colorbox.nvim/issues/173)) ([e16accd](https://github.com/linrongbin16/colorbox.nvim/commit/e16accd3721f5ed660256c7140c6002542dd1d6b))


### Performance Improvements

* **collector:** add more colors ([#173](https://github.com/linrongbin16/colorbox.nvim/issues/173)) ([e16accd](https://github.com/linrongbin16/colorbox.nvim/commit/e16accd3721f5ed660256c7140c6002542dd1d6b))

## [2.0.1](https://github.com/linrongbin16/colorbox.nvim/compare/v2.0.0...v2.0.1) (2024-01-23)


### Bug Fixes

* **collector:** fix exception in collector ([#161](https://github.com/linrongbin16/colorbox.nvim/issues/161)) ([d9f00e4](https://github.com/linrongbin16/colorbox.nvim/commit/d9f00e4a5b3cbe372d760a1b7a196e41866843cf))
* **collector:** fix last git commit date time fetching in vsc ([#163](https://github.com/linrongbin16/colorbox.nvim/issues/163)) ([0ec2309](https://github.com/linrongbin16/colorbox.nvim/commit/0ec23093d64d10afbc7149d4c752e5a3945ed167))
* **db:** fix db.json ([#166](https://github.com/linrongbin16/colorbox.nvim/issues/166)) ([31622ed](https://github.com/linrongbin16/colorbox.nvim/commit/31622edbac3c3375d8d4f2f5df12890ad1bfba81))

## [2.0.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.14.2...v2.0.0) (2024-01-15)


### ⚠ BREAKING CHANGES

* **filter:** enable color when filter returns true ([#158](https://github.com/linrongbin16/colorbox.nvim/issues/158))

### Performance Improvements

* **filter:** enable color when filter returns true ([#158](https://github.com/linrongbin16/colorbox.nvim/issues/158)) ([08b9d4b](https://github.com/linrongbin16/colorbox.nvim/commit/08b9d4b1439348bd11e625a98dbfaedbee1423cf))

## [1.14.2](https://github.com/linrongbin16/colorbox.nvim/compare/v1.14.1...v1.14.2) (2023-12-30)


### Bug Fixes

* **info:** safe scale refactor ([#155](https://github.com/linrongbin16/colorbox.nvim/issues/155)) ([6809503](https://github.com/linrongbin16/colorbox.nvim/commit/6809503f906b508ebfe70bd03dd2e1ddda252dfb))

## [1.14.1](https://github.com/linrongbin16/colorbox.nvim/compare/v1.14.0...v1.14.1) (2023-12-27)


### Performance Improvements

* **command:** improve 'info' sub command behavior ([#150](https://github.com/linrongbin16/colorbox.nvim/issues/150)) ([801326c](https://github.com/linrongbin16/colorbox.nvim/commit/801326ceb388961dbd9fbab5272bddcfe98a4e1c))

## [1.14.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.9...v1.14.0) (2023-12-27)


### Features

* **collector:** collect more (&gt;= 500 stars) colors ([#148](https://github.com/linrongbin16/colorbox.nvim/issues/148)) ([83e31af](https://github.com/linrongbin16/colorbox.nvim/commit/83e31afb7b89817d7b7bb3442165a01188489982))
* **command:** add 'info' sub command for detailed info ([#148](https://github.com/linrongbin16/colorbox.nvim/issues/148)) ([83e31af](https://github.com/linrongbin16/colorbox.nvim/commit/83e31afb7b89817d7b7bb3442165a01188489982))


### Bug Fixes

* **policy:** fix reverse order exceptions ([#148](https://github.com/linrongbin16/colorbox.nvim/issues/148)) ([83e31af](https://github.com/linrongbin16/colorbox.nvim/commit/83e31afb7b89817d7b7bb3442165a01188489982))


### Performance Improvements

* **test:** improve test cases ([#148](https://github.com/linrongbin16/colorbox.nvim/issues/148)) ([83e31af](https://github.com/linrongbin16/colorbox.nvim/commit/83e31afb7b89817d7b7bb3442165a01188489982))

## [1.13.9](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.8...v1.13.9) (2023-12-26)


### Performance Improvements

* **configs:** rename 'bufferchanged' to 'filetype' ([#145](https://github.com/linrongbin16/colorbox.nvim/issues/145)) ([eb5393b](https://github.com/linrongbin16/colorbox.nvim/commit/eb5393be2b64424ccadbdc297abbb7fa7b4cb679))
* **test:** improve unit tests ([#145](https://github.com/linrongbin16/colorbox.nvim/issues/145)) ([eb5393b](https://github.com/linrongbin16/colorbox.nvim/commit/eb5393be2b64424ccadbdc297abbb7fa7b4cb679))

## [1.13.8](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.7...v1.13.8) (2023-12-26)


### Bug Fixes

* **filter:** fix 'primary' filter ([#143](https://github.com/linrongbin16/colorbox.nvim/issues/143)) ([4c5dbda](https://github.com/linrongbin16/colorbox.nvim/commit/4c5dbda63646bfd85c00cfc6dd6eb7feb47f3bff))


### Performance Improvements

* **shuffle:** use commons random API ([#143](https://github.com/linrongbin16/colorbox.nvim/issues/143)) ([4c5dbda](https://github.com/linrongbin16/colorbox.nvim/commit/4c5dbda63646bfd85c00cfc6dd6eb7feb47f3bff))

## [1.13.7](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.6...v1.13.7) (2023-12-26)


### Bug Fixes

* **policy:** fix 'shuffle' random ([#141](https://github.com/linrongbin16/colorbox.nvim/issues/141)) ([9372112](https://github.com/linrongbin16/colorbox.nvim/commit/93721123cbefafc192789a787071b493d5e2e1bd))

## [1.13.6](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.5...v1.13.6) (2023-12-18)


### Performance Improvements

* **test:** improve test cases ([#135](https://github.com/linrongbin16/colorbox.nvim/issues/135)) ([5b0da01](https://github.com/linrongbin16/colorbox.nvim/commit/5b0da018a29ca47f8700cd8b602dec457555b79a))

## [1.13.5](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.4...v1.13.5) (2023-12-17)


### Bug Fixes

* **unpack:** fix unpack ([#132](https://github.com/linrongbin16/colorbox.nvim/issues/132)) ([a483f98](https://github.com/linrongbin16/colorbox.nvim/commit/a483f984470dda88f29986a83a13d50f8b6f9f4a))

## [1.13.4](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.3...v1.13.4) (2023-12-17)


### Performance Improvements

* **commons:** migrate to commons library ([#129](https://github.com/linrongbin16/colorbox.nvim/issues/129)) ([b1980a7](https://github.com/linrongbin16/colorbox.nvim/commit/b1980a7289bfb390ea738c957427b1ce9f3e0552))

## [1.13.3](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.2...v1.13.3) (2023-12-08)


### Performance Improvements

* **ci:** try upload luarocks again3 ([#124](https://github.com/linrongbin16/colorbox.nvim/issues/124)) ([a2199c1](https://github.com/linrongbin16/colorbox.nvim/commit/a2199c12b84278943cb0627b69714f44385e73d2))

## [1.13.2](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.1...v1.13.2) (2023-12-08)


### Performance Improvements

* **ci:** try again ([#122](https://github.com/linrongbin16/colorbox.nvim/issues/122)) ([a10c6ea](https://github.com/linrongbin16/colorbox.nvim/commit/a10c6eaca5f69570cc00bcabfff7e24981486a3b))

## [1.13.1](https://github.com/linrongbin16/colorbox.nvim/compare/v1.13.0...v1.13.1) (2023-12-08)


### Performance Improvements

* **ci:** try trigger luarocks ci ([#120](https://github.com/linrongbin16/colorbox.nvim/issues/120)) ([4dd969e](https://github.com/linrongbin16/colorbox.nvim/commit/4dd969e6117775c524961531132ff09930fa6890))

## [1.13.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.12.4...v1.13.0) (2023-12-08)


### Features

* **command:** add `Colorbox` command and provide `reinstall` option ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* **config:** add `cache_dir` option ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **controller:** provide `update` option ([#57](https://github.com/linrongbin16/colorbox.nvim/issues/57)) ([c6338ff](https://github.com/linrongbin16/colorbox.nvim/commit/c6338ff63452e78e6492a83da19e38e5646ce241))
* **filter:** add 'primary' filter ([#21](https://github.com/linrongbin16/colorbox.nvim/issues/21)) ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **fixed interval:** support fixed interval timing and policy ([#59](https://github.com/linrongbin16/colorbox.nvim/issues/59)) ([f0fcd55](https://github.com/linrongbin16/colorbox.nvim/commit/f0fcd552d3b9d9142b101d070034f1f09008a28d))
* **install:** support 'reinstall' on Windows ([#62](https://github.com/linrongbin16/colorbox.nvim/issues/62)) ([9f00c7b](https://github.com/linrongbin16/colorbox.nvim/commit/9f00c7ba8814b8d2d5b1a8000d068a949954a3f7))
* **install:** use `neovim` branch for `lifepillar/vim-solarized8` ([#52](https://github.com/linrongbin16/colorbox.nvim/issues/52)) ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* MPV done ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **policy:** add 'by filetype' policy ([#72](https://github.com/linrongbin16/colorbox.nvim/issues/72)) ([2910a20](https://github.com/linrongbin16/colorbox.nvim/commit/2910a203698851f50b2d9e5754978d7939d3769f))
* **policy:** add 'single' policy ([#70](https://github.com/linrongbin16/colorbox.nvim/issues/70)) ([da537b4](https://github.com/linrongbin16/colorbox.nvim/commit/da537b4aa5aa9f02692d815b4eddce15db2c65dc))
* **policy:** add `reverse_order` policy ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))
* **policy:** play in order ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* update docs ([#19](https://github.com/linrongbin16/colorbox.nvim/issues/19)) ([0e7a564](https://github.com/linrongbin16/colorbox.nvim/commit/0e7a564ef92073a172356acadf183f8f6b7965df))
* **update:** auto-update ([#28](https://github.com/linrongbin16/colorbox.nvim/issues/28)) ([a730726](https://github.com/linrongbin16/colorbox.nvim/commit/a73072677d9ec24006818710531cd3bcc7200529))


### Bug Fixes

* **ci:** fix action-create-tag v1 ([#88](https://github.com/linrongbin16/colorbox.nvim/issues/88)) ([3987942](https://github.com/linrongbin16/colorbox.nvim/commit/3987942a2d488321faf2f886547cf567c6dbf022))
* **ci:** fix infinite PR loop by please-release action ([#82](https://github.com/linrongbin16/colorbox.nvim/issues/82)) ([a984910](https://github.com/linrongbin16/colorbox.nvim/commit/a984910bd59768281f93ef6c69f7f2603d8a7cba))
* **ci:** fix please-release action ([#87](https://github.com/linrongbin16/colorbox.nvim/issues/87)) ([1d93e3e](https://github.com/linrongbin16/colorbox.nvim/commit/1d93e3edd04edf297bba9b50a136f8f7319838f7))
* **ci:** fix release-drafter ([#83](https://github.com/linrongbin16/colorbox.nvim/issues/83)) ([b4ffdb4](https://github.com/linrongbin16/colorbox.nvim/commit/b4ffdb41b942cd9f599ee5a6c613fc7eb539ef00))
* **ci:** fix release-drafter config ([#84](https://github.com/linrongbin16/colorbox.nvim/issues/84)) ([77f8d17](https://github.com/linrongbin16/colorbox.nvim/commit/77f8d175e0847c7c42b0d0354af27b046676cb54))
* **ci:** revert luarocks CI and please-release ([#99](https://github.com/linrongbin16/colorbox.nvim/issues/99)) ([779f67d](https://github.com/linrongbin16/colorbox.nvim/commit/779f67d82e3785c641157d0026a411db6f4fe442))
* **ci:** use please-release v4, remove 'package-name' ([#94](https://github.com/linrongbin16/colorbox.nvim/issues/94)) ([c509f36](https://github.com/linrongbin16/colorbox.nvim/commit/c509f36c2d0f71768787d3d86d0fa526117271fc))
* **filter:** fix 'primary' filter ([91e89c9](https://github.com/linrongbin16/colorbox.nvim/commit/91e89c9c553c3df59e6ebf26bb1038450f883c30))
* **install:** fix NPE in first installation ([#24](https://github.com/linrongbin16/colorbox.nvim/issues/24)) ([2871108](https://github.com/linrongbin16/colorbox.nvim/commit/2871108ef8093da431df47eea57558c6144f862c))
* **install:** fix NPE while installation ([#64](https://github.com/linrongbin16/colorbox.nvim/issues/64)) ([3aa8c2d](https://github.com/linrongbin16/colorbox.nvim/commit/3aa8c2d5fb9a412f643baddea4d0b3840d2092cb))


### Performance Improvements

* **build:** async run to avoid blocking ([#46](https://github.com/linrongbin16/colorbox.nvim/issues/46)) ([814a927](https://github.com/linrongbin16/colorbox.nvim/commit/814a927a14669af4c8d5c86f22cf75488cf408ee))
* **build:** improve git submodules installation speed ([#50](https://github.com/linrongbin16/colorbox.nvim/issues/50)) ([18ce09e](https://github.com/linrongbin16/colorbox.nvim/commit/18ce09eb234a8788cdadcfd56ffff9818fceadb5))
* **ci:** reduce to weekly run ([#30](https://github.com/linrongbin16/colorbox.nvim/issues/30)) ([f4f7603](https://github.com/linrongbin16/colorbox.nvim/commit/f4f7603285ad6a8df83d3312550bbf7ac3dbdda2))
* **ci:** try again personal token ([#105](https://github.com/linrongbin16/colorbox.nvim/issues/105)) ([694cf32](https://github.com/linrongbin16/colorbox.nvim/commit/694cf328f683425d22f049209de6aaf4ddc4f7ce))
* **ci:** upload luarocks ([#101](https://github.com/linrongbin16/colorbox.nvim/issues/101)) ([ae06ac4](https://github.com/linrongbin16/colorbox.nvim/commit/ae06ac480e766b7e21415d8e54a7d85c8c25b375))
* **ci:** upload luarocks ([#77](https://github.com/linrongbin16/colorbox.nvim/issues/77)) ([b6c7f59](https://github.com/linrongbin16/colorbox.nvim/commit/b6c7f593a005c40c185fb36966d075c799e19239))
* **ci:** upload luarocks ([#91](https://github.com/linrongbin16/colorbox.nvim/issues/91)) ([55be084](https://github.com/linrongbin16/colorbox.nvim/commit/55be08426d0f98a120539185445e187d16987327))
* **collector:** improve colorschemes list ([#66](https://github.com/linrongbin16/colorbox.nvim/issues/66)) ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **colorschemes:** improve COLORSCHEMES list ([#71](https://github.com/linrongbin16/colorbox.nvim/issues/71)) ([5211c28](https://github.com/linrongbin16/colorbox.nvim/commit/5211c282596e37755908908f9e04146b947fc9d3))
* **config:** by default only enable 'primary' colors ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **init:** improve speed via build index when initializing ([#37](https://github.com/linrongbin16/colorbox.nvim/issues/37)) ([8782111](https://github.com/linrongbin16/colorbox.nvim/commit/8782111bdfbe42412a3b3cf00852a9da79f99443))
* **install:** optimize install logs ([#41](https://github.com/linrongbin16/colorbox.nvim/issues/41)) ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **install:** optimize log message ([#75](https://github.com/linrongbin16/colorbox.nvim/issues/75)) ([1ddde8c](https://github.com/linrongbin16/colorbox.nvim/commit/1ddde8c5ebfa4041952757e9d33da799ff039aa6))
* **load:** improve loading data speed ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **policy:** remove 'name' from fixed interval policy ([#68](https://github.com/linrongbin16/colorbox.nvim/issues/68)) ([759d524](https://github.com/linrongbin16/colorbox.nvim/commit/759d524f2e244a2718836b0498a66391f0ab3a14))
* **refactor:** improve code structure ([#33](https://github.com/linrongbin16/colorbox.nvim/issues/33)) ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **shuffle:** better bitwise xor for random integer ([#44](https://github.com/linrongbin16/colorbox.nvim/issues/44)) ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))


### Reverts

* **ci:** revert please-release action to v3 ([#92](https://github.com/linrongbin16/colorbox.nvim/issues/92)) ([8f78495](https://github.com/linrongbin16/colorbox.nvim/commit/8f784950518effa09d69f373b08c52480c4924de))
* **ci:** use please-release ([#85](https://github.com/linrongbin16/colorbox.nvim/issues/85)) ([d4b2eab](https://github.com/linrongbin16/colorbox.nvim/commit/d4b2eabc2d32987d480320402efc10d2e1b8ccf8))

## [1.12.4](https://github.com/linrongbin16/colorbox.nvim/compare/v1.12.3...v1.12.4) (2023-12-08)


### Bug Fixes

* **ci:** fix action-create-tag v1 ([#88](https://github.com/linrongbin16/colorbox.nvim/issues/88)) ([3987942](https://github.com/linrongbin16/colorbox.nvim/commit/3987942a2d488321faf2f886547cf567c6dbf022))
* **ci:** fix infinite PR loop by please-release action ([#82](https://github.com/linrongbin16/colorbox.nvim/issues/82)) ([a984910](https://github.com/linrongbin16/colorbox.nvim/commit/a984910bd59768281f93ef6c69f7f2603d8a7cba))
* **ci:** fix please-release action ([#87](https://github.com/linrongbin16/colorbox.nvim/issues/87)) ([1d93e3e](https://github.com/linrongbin16/colorbox.nvim/commit/1d93e3edd04edf297bba9b50a136f8f7319838f7))
* **ci:** fix release-drafter ([#83](https://github.com/linrongbin16/colorbox.nvim/issues/83)) ([b4ffdb4](https://github.com/linrongbin16/colorbox.nvim/commit/b4ffdb41b942cd9f599ee5a6c613fc7eb539ef00))
* **ci:** fix release-drafter config ([#84](https://github.com/linrongbin16/colorbox.nvim/issues/84)) ([77f8d17](https://github.com/linrongbin16/colorbox.nvim/commit/77f8d175e0847c7c42b0d0354af27b046676cb54))
* **ci:** revert luarocks CI and please-release ([#99](https://github.com/linrongbin16/colorbox.nvim/issues/99)) ([779f67d](https://github.com/linrongbin16/colorbox.nvim/commit/779f67d82e3785c641157d0026a411db6f4fe442))
* **ci:** use please-release v4, remove 'package-name' ([#94](https://github.com/linrongbin16/colorbox.nvim/issues/94)) ([c509f36](https://github.com/linrongbin16/colorbox.nvim/commit/c509f36c2d0f71768787d3d86d0fa526117271fc))


### Performance Improvements

* **ci:** try again personal token ([#105](https://github.com/linrongbin16/colorbox.nvim/issues/105)) ([694cf32](https://github.com/linrongbin16/colorbox.nvim/commit/694cf328f683425d22f049209de6aaf4ddc4f7ce))
* **ci:** upload luarocks ([#101](https://github.com/linrongbin16/colorbox.nvim/issues/101)) ([ae06ac4](https://github.com/linrongbin16/colorbox.nvim/commit/ae06ac480e766b7e21415d8e54a7d85c8c25b375))
* **ci:** upload luarocks ([#91](https://github.com/linrongbin16/colorbox.nvim/issues/91)) ([55be084](https://github.com/linrongbin16/colorbox.nvim/commit/55be08426d0f98a120539185445e187d16987327))


### Reverts

* **ci:** revert please-release action to v3 ([#92](https://github.com/linrongbin16/colorbox.nvim/issues/92)) ([8f78495](https://github.com/linrongbin16/colorbox.nvim/commit/8f784950518effa09d69f373b08c52480c4924de))
* **ci:** use please-release ([#85](https://github.com/linrongbin16/colorbox.nvim/issues/85)) ([d4b2eab](https://github.com/linrongbin16/colorbox.nvim/commit/d4b2eabc2d32987d480320402efc10d2e1b8ccf8))

## [1.12.3](https://github.com/linrongbin16/colorbox.nvim/compare/v1.12.2...v1.12.3) (2023-12-08)


### Bug Fixes

* **ci:** fix action-create-tag v1 ([#88](https://github.com/linrongbin16/colorbox.nvim/issues/88)) ([3987942](https://github.com/linrongbin16/colorbox.nvim/commit/3987942a2d488321faf2f886547cf567c6dbf022))
* **ci:** fix infinite PR loop by please-release action ([#82](https://github.com/linrongbin16/colorbox.nvim/issues/82)) ([a984910](https://github.com/linrongbin16/colorbox.nvim/commit/a984910bd59768281f93ef6c69f7f2603d8a7cba))
* **ci:** fix please-release action ([#87](https://github.com/linrongbin16/colorbox.nvim/issues/87)) ([1d93e3e](https://github.com/linrongbin16/colorbox.nvim/commit/1d93e3edd04edf297bba9b50a136f8f7319838f7))
* **ci:** fix release-drafter ([#83](https://github.com/linrongbin16/colorbox.nvim/issues/83)) ([b4ffdb4](https://github.com/linrongbin16/colorbox.nvim/commit/b4ffdb41b942cd9f599ee5a6c613fc7eb539ef00))
* **ci:** fix release-drafter config ([#84](https://github.com/linrongbin16/colorbox.nvim/issues/84)) ([77f8d17](https://github.com/linrongbin16/colorbox.nvim/commit/77f8d175e0847c7c42b0d0354af27b046676cb54))
* **ci:** revert luarocks CI and please-release ([#99](https://github.com/linrongbin16/colorbox.nvim/issues/99)) ([779f67d](https://github.com/linrongbin16/colorbox.nvim/commit/779f67d82e3785c641157d0026a411db6f4fe442))
* **ci:** use please-release v4, remove 'package-name' ([#94](https://github.com/linrongbin16/colorbox.nvim/issues/94)) ([c509f36](https://github.com/linrongbin16/colorbox.nvim/commit/c509f36c2d0f71768787d3d86d0fa526117271fc))


### Performance Improvements

* **ci:** try again personal token ([#105](https://github.com/linrongbin16/colorbox.nvim/issues/105)) ([694cf32](https://github.com/linrongbin16/colorbox.nvim/commit/694cf328f683425d22f049209de6aaf4ddc4f7ce))
* **ci:** upload luarocks ([#101](https://github.com/linrongbin16/colorbox.nvim/issues/101)) ([ae06ac4](https://github.com/linrongbin16/colorbox.nvim/commit/ae06ac480e766b7e21415d8e54a7d85c8c25b375))
* **ci:** upload luarocks ([#91](https://github.com/linrongbin16/colorbox.nvim/issues/91)) ([55be084](https://github.com/linrongbin16/colorbox.nvim/commit/55be08426d0f98a120539185445e187d16987327))


### Reverts

* **ci:** revert please-release action to v3 ([#92](https://github.com/linrongbin16/colorbox.nvim/issues/92)) ([8f78495](https://github.com/linrongbin16/colorbox.nvim/commit/8f784950518effa09d69f373b08c52480c4924de))
* **ci:** use please-release ([#85](https://github.com/linrongbin16/colorbox.nvim/issues/85)) ([d4b2eab](https://github.com/linrongbin16/colorbox.nvim/commit/d4b2eabc2d32987d480320402efc10d2e1b8ccf8))

## [1.12.2](https://github.com/linrongbin16/colorbox.nvim/compare/v1.12.1...v1.12.2) (2023-12-08)


### Performance Improvements

* **ci:** try again personal token ([#105](https://github.com/linrongbin16/colorbox.nvim/issues/105)) ([694cf32](https://github.com/linrongbin16/colorbox.nvim/commit/694cf328f683425d22f049209de6aaf4ddc4f7ce))

## [1.12.1](https://github.com/linrongbin16/colorbox.nvim/compare/v1.12.0...v1.12.1) (2023-12-08)


### Performance Improvements

* **ci:** upload luarocks ([#101](https://github.com/linrongbin16/colorbox.nvim/issues/101)) ([ae06ac4](https://github.com/linrongbin16/colorbox.nvim/commit/ae06ac480e766b7e21415d8e54a7d85c8c25b375))

## [1.12.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.11.0...v1.12.0) (2023-12-08)


### Features

* **command:** add `Colorbox` command and provide `reinstall` option ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* **config:** add `cache_dir` option ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **controller:** provide `update` option ([#57](https://github.com/linrongbin16/colorbox.nvim/issues/57)) ([c6338ff](https://github.com/linrongbin16/colorbox.nvim/commit/c6338ff63452e78e6492a83da19e38e5646ce241))
* **filter:** add 'primary' filter ([#21](https://github.com/linrongbin16/colorbox.nvim/issues/21)) ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **fixed interval:** support fixed interval timing and policy ([#59](https://github.com/linrongbin16/colorbox.nvim/issues/59)) ([f0fcd55](https://github.com/linrongbin16/colorbox.nvim/commit/f0fcd552d3b9d9142b101d070034f1f09008a28d))
* **install:** support 'reinstall' on Windows ([#62](https://github.com/linrongbin16/colorbox.nvim/issues/62)) ([9f00c7b](https://github.com/linrongbin16/colorbox.nvim/commit/9f00c7ba8814b8d2d5b1a8000d068a949954a3f7))
* **install:** use `neovim` branch for `lifepillar/vim-solarized8` ([#52](https://github.com/linrongbin16/colorbox.nvim/issues/52)) ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* MPV done ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **policy:** add 'by filetype' policy ([#72](https://github.com/linrongbin16/colorbox.nvim/issues/72)) ([2910a20](https://github.com/linrongbin16/colorbox.nvim/commit/2910a203698851f50b2d9e5754978d7939d3769f))
* **policy:** add 'single' policy ([#70](https://github.com/linrongbin16/colorbox.nvim/issues/70)) ([da537b4](https://github.com/linrongbin16/colorbox.nvim/commit/da537b4aa5aa9f02692d815b4eddce15db2c65dc))
* **policy:** add `reverse_order` policy ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))
* **policy:** play in order ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* update docs ([#19](https://github.com/linrongbin16/colorbox.nvim/issues/19)) ([0e7a564](https://github.com/linrongbin16/colorbox.nvim/commit/0e7a564ef92073a172356acadf183f8f6b7965df))
* **update:** auto-update ([#28](https://github.com/linrongbin16/colorbox.nvim/issues/28)) ([a730726](https://github.com/linrongbin16/colorbox.nvim/commit/a73072677d9ec24006818710531cd3bcc7200529))


### Bug Fixes

* **ci:** fix action-create-tag v1 ([#88](https://github.com/linrongbin16/colorbox.nvim/issues/88)) ([3987942](https://github.com/linrongbin16/colorbox.nvim/commit/3987942a2d488321faf2f886547cf567c6dbf022))
* **ci:** fix infinite PR loop by please-release action ([#82](https://github.com/linrongbin16/colorbox.nvim/issues/82)) ([a984910](https://github.com/linrongbin16/colorbox.nvim/commit/a984910bd59768281f93ef6c69f7f2603d8a7cba))
* **ci:** fix please-release action ([#87](https://github.com/linrongbin16/colorbox.nvim/issues/87)) ([1d93e3e](https://github.com/linrongbin16/colorbox.nvim/commit/1d93e3edd04edf297bba9b50a136f8f7319838f7))
* **ci:** fix release-drafter ([#83](https://github.com/linrongbin16/colorbox.nvim/issues/83)) ([b4ffdb4](https://github.com/linrongbin16/colorbox.nvim/commit/b4ffdb41b942cd9f599ee5a6c613fc7eb539ef00))
* **ci:** fix release-drafter config ([#84](https://github.com/linrongbin16/colorbox.nvim/issues/84)) ([77f8d17](https://github.com/linrongbin16/colorbox.nvim/commit/77f8d175e0847c7c42b0d0354af27b046676cb54))
* **ci:** revert luarocks CI and please-release ([#99](https://github.com/linrongbin16/colorbox.nvim/issues/99)) ([779f67d](https://github.com/linrongbin16/colorbox.nvim/commit/779f67d82e3785c641157d0026a411db6f4fe442))
* **ci:** use please-release v4, remove 'package-name' ([#94](https://github.com/linrongbin16/colorbox.nvim/issues/94)) ([c509f36](https://github.com/linrongbin16/colorbox.nvim/commit/c509f36c2d0f71768787d3d86d0fa526117271fc))
* **filter:** fix 'primary' filter ([91e89c9](https://github.com/linrongbin16/colorbox.nvim/commit/91e89c9c553c3df59e6ebf26bb1038450f883c30))
* **install:** fix NPE in first installation ([#24](https://github.com/linrongbin16/colorbox.nvim/issues/24)) ([2871108](https://github.com/linrongbin16/colorbox.nvim/commit/2871108ef8093da431df47eea57558c6144f862c))
* **install:** fix NPE while installation ([#64](https://github.com/linrongbin16/colorbox.nvim/issues/64)) ([3aa8c2d](https://github.com/linrongbin16/colorbox.nvim/commit/3aa8c2d5fb9a412f643baddea4d0b3840d2092cb))


### Performance Improvements

* **build:** async run to avoid blocking ([#46](https://github.com/linrongbin16/colorbox.nvim/issues/46)) ([814a927](https://github.com/linrongbin16/colorbox.nvim/commit/814a927a14669af4c8d5c86f22cf75488cf408ee))
* **build:** improve git submodules installation speed ([#50](https://github.com/linrongbin16/colorbox.nvim/issues/50)) ([18ce09e](https://github.com/linrongbin16/colorbox.nvim/commit/18ce09eb234a8788cdadcfd56ffff9818fceadb5))
* **ci:** reduce to weekly run ([#30](https://github.com/linrongbin16/colorbox.nvim/issues/30)) ([f4f7603](https://github.com/linrongbin16/colorbox.nvim/commit/f4f7603285ad6a8df83d3312550bbf7ac3dbdda2))
* **ci:** upload luarocks ([#77](https://github.com/linrongbin16/colorbox.nvim/issues/77)) ([b6c7f59](https://github.com/linrongbin16/colorbox.nvim/commit/b6c7f593a005c40c185fb36966d075c799e19239))
* **ci:** upload luarocks ([#91](https://github.com/linrongbin16/colorbox.nvim/issues/91)) ([55be084](https://github.com/linrongbin16/colorbox.nvim/commit/55be08426d0f98a120539185445e187d16987327))
* **collector:** improve colorschemes list ([#66](https://github.com/linrongbin16/colorbox.nvim/issues/66)) ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **colorschemes:** improve COLORSCHEMES list ([#71](https://github.com/linrongbin16/colorbox.nvim/issues/71)) ([5211c28](https://github.com/linrongbin16/colorbox.nvim/commit/5211c282596e37755908908f9e04146b947fc9d3))
* **config:** by default only enable 'primary' colors ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **init:** improve speed via build index when initializing ([#37](https://github.com/linrongbin16/colorbox.nvim/issues/37)) ([8782111](https://github.com/linrongbin16/colorbox.nvim/commit/8782111bdfbe42412a3b3cf00852a9da79f99443))
* **install:** optimize install logs ([#41](https://github.com/linrongbin16/colorbox.nvim/issues/41)) ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **install:** optimize log message ([#75](https://github.com/linrongbin16/colorbox.nvim/issues/75)) ([1ddde8c](https://github.com/linrongbin16/colorbox.nvim/commit/1ddde8c5ebfa4041952757e9d33da799ff039aa6))
* **load:** improve loading data speed ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **policy:** remove 'name' from fixed interval policy ([#68](https://github.com/linrongbin16/colorbox.nvim/issues/68)) ([759d524](https://github.com/linrongbin16/colorbox.nvim/commit/759d524f2e244a2718836b0498a66391f0ab3a14))
* **refactor:** improve code structure ([#33](https://github.com/linrongbin16/colorbox.nvim/issues/33)) ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **shuffle:** better bitwise xor for random integer ([#44](https://github.com/linrongbin16/colorbox.nvim/issues/44)) ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))


### Reverts

* **ci:** revert please-release action to v3 ([#92](https://github.com/linrongbin16/colorbox.nvim/issues/92)) ([8f78495](https://github.com/linrongbin16/colorbox.nvim/commit/8f784950518effa09d69f373b08c52480c4924de))
* **ci:** use please-release ([#85](https://github.com/linrongbin16/colorbox.nvim/issues/85)) ([d4b2eab](https://github.com/linrongbin16/colorbox.nvim/commit/d4b2eabc2d32987d480320402efc10d2e1b8ccf8))

## [1.12.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.11.0...v1.12.0) (2023-12-08)


### Features

* **command:** add `Colorbox` command and provide `reinstall` option ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* **config:** add `cache_dir` option ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **controller:** provide `update` option ([#57](https://github.com/linrongbin16/colorbox.nvim/issues/57)) ([c6338ff](https://github.com/linrongbin16/colorbox.nvim/commit/c6338ff63452e78e6492a83da19e38e5646ce241))
* **filter:** add 'primary' filter ([#21](https://github.com/linrongbin16/colorbox.nvim/issues/21)) ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **fixed interval:** support fixed interval timing and policy ([#59](https://github.com/linrongbin16/colorbox.nvim/issues/59)) ([f0fcd55](https://github.com/linrongbin16/colorbox.nvim/commit/f0fcd552d3b9d9142b101d070034f1f09008a28d))
* **install:** support 'reinstall' on Windows ([#62](https://github.com/linrongbin16/colorbox.nvim/issues/62)) ([9f00c7b](https://github.com/linrongbin16/colorbox.nvim/commit/9f00c7ba8814b8d2d5b1a8000d068a949954a3f7))
* **install:** use `neovim` branch for `lifepillar/vim-solarized8` ([#52](https://github.com/linrongbin16/colorbox.nvim/issues/52)) ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* MPV done ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **policy:** add 'by filetype' policy ([#72](https://github.com/linrongbin16/colorbox.nvim/issues/72)) ([2910a20](https://github.com/linrongbin16/colorbox.nvim/commit/2910a203698851f50b2d9e5754978d7939d3769f))
* **policy:** add 'single' policy ([#70](https://github.com/linrongbin16/colorbox.nvim/issues/70)) ([da537b4](https://github.com/linrongbin16/colorbox.nvim/commit/da537b4aa5aa9f02692d815b4eddce15db2c65dc))
* **policy:** add `reverse_order` policy ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))
* **policy:** play in order ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* update docs ([#19](https://github.com/linrongbin16/colorbox.nvim/issues/19)) ([0e7a564](https://github.com/linrongbin16/colorbox.nvim/commit/0e7a564ef92073a172356acadf183f8f6b7965df))
* **update:** auto-update ([#28](https://github.com/linrongbin16/colorbox.nvim/issues/28)) ([a730726](https://github.com/linrongbin16/colorbox.nvim/commit/a73072677d9ec24006818710531cd3bcc7200529))


### Bug Fixes

* **ci:** fix action-create-tag v1 ([#88](https://github.com/linrongbin16/colorbox.nvim/issues/88)) ([3987942](https://github.com/linrongbin16/colorbox.nvim/commit/3987942a2d488321faf2f886547cf567c6dbf022))
* **ci:** fix infinite PR loop by please-release action ([#82](https://github.com/linrongbin16/colorbox.nvim/issues/82)) ([a984910](https://github.com/linrongbin16/colorbox.nvim/commit/a984910bd59768281f93ef6c69f7f2603d8a7cba))
* **ci:** fix please-release action ([#87](https://github.com/linrongbin16/colorbox.nvim/issues/87)) ([1d93e3e](https://github.com/linrongbin16/colorbox.nvim/commit/1d93e3edd04edf297bba9b50a136f8f7319838f7))
* **ci:** fix release-drafter ([#83](https://github.com/linrongbin16/colorbox.nvim/issues/83)) ([b4ffdb4](https://github.com/linrongbin16/colorbox.nvim/commit/b4ffdb41b942cd9f599ee5a6c613fc7eb539ef00))
* **ci:** fix release-drafter config ([#84](https://github.com/linrongbin16/colorbox.nvim/issues/84)) ([77f8d17](https://github.com/linrongbin16/colorbox.nvim/commit/77f8d175e0847c7c42b0d0354af27b046676cb54))
* **ci:** use please-release v4, remove 'package-name' ([#94](https://github.com/linrongbin16/colorbox.nvim/issues/94)) ([c509f36](https://github.com/linrongbin16/colorbox.nvim/commit/c509f36c2d0f71768787d3d86d0fa526117271fc))
* **filter:** fix 'primary' filter ([91e89c9](https://github.com/linrongbin16/colorbox.nvim/commit/91e89c9c553c3df59e6ebf26bb1038450f883c30))
* **install:** fix NPE in first installation ([#24](https://github.com/linrongbin16/colorbox.nvim/issues/24)) ([2871108](https://github.com/linrongbin16/colorbox.nvim/commit/2871108ef8093da431df47eea57558c6144f862c))
* **install:** fix NPE while installation ([#64](https://github.com/linrongbin16/colorbox.nvim/issues/64)) ([3aa8c2d](https://github.com/linrongbin16/colorbox.nvim/commit/3aa8c2d5fb9a412f643baddea4d0b3840d2092cb))


### Performance Improvements

* **build:** async run to avoid blocking ([#46](https://github.com/linrongbin16/colorbox.nvim/issues/46)) ([814a927](https://github.com/linrongbin16/colorbox.nvim/commit/814a927a14669af4c8d5c86f22cf75488cf408ee))
* **build:** improve git submodules installation speed ([#50](https://github.com/linrongbin16/colorbox.nvim/issues/50)) ([18ce09e](https://github.com/linrongbin16/colorbox.nvim/commit/18ce09eb234a8788cdadcfd56ffff9818fceadb5))
* **ci:** reduce to weekly run ([#30](https://github.com/linrongbin16/colorbox.nvim/issues/30)) ([f4f7603](https://github.com/linrongbin16/colorbox.nvim/commit/f4f7603285ad6a8df83d3312550bbf7ac3dbdda2))
* **ci:** upload luarocks ([#77](https://github.com/linrongbin16/colorbox.nvim/issues/77)) ([b6c7f59](https://github.com/linrongbin16/colorbox.nvim/commit/b6c7f593a005c40c185fb36966d075c799e19239))
* **ci:** upload luarocks ([#91](https://github.com/linrongbin16/colorbox.nvim/issues/91)) ([55be084](https://github.com/linrongbin16/colorbox.nvim/commit/55be08426d0f98a120539185445e187d16987327))
* **collector:** improve colorschemes list ([#66](https://github.com/linrongbin16/colorbox.nvim/issues/66)) ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **colorschemes:** improve COLORSCHEMES list ([#71](https://github.com/linrongbin16/colorbox.nvim/issues/71)) ([5211c28](https://github.com/linrongbin16/colorbox.nvim/commit/5211c282596e37755908908f9e04146b947fc9d3))
* **config:** by default only enable 'primary' colors ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **init:** improve speed via build index when initializing ([#37](https://github.com/linrongbin16/colorbox.nvim/issues/37)) ([8782111](https://github.com/linrongbin16/colorbox.nvim/commit/8782111bdfbe42412a3b3cf00852a9da79f99443))
* **install:** optimize install logs ([#41](https://github.com/linrongbin16/colorbox.nvim/issues/41)) ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **install:** optimize log message ([#75](https://github.com/linrongbin16/colorbox.nvim/issues/75)) ([1ddde8c](https://github.com/linrongbin16/colorbox.nvim/commit/1ddde8c5ebfa4041952757e9d33da799ff039aa6))
* **load:** improve loading data speed ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **policy:** remove 'name' from fixed interval policy ([#68](https://github.com/linrongbin16/colorbox.nvim/issues/68)) ([759d524](https://github.com/linrongbin16/colorbox.nvim/commit/759d524f2e244a2718836b0498a66391f0ab3a14))
* **refactor:** improve code structure ([#33](https://github.com/linrongbin16/colorbox.nvim/issues/33)) ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **shuffle:** better bitwise xor for random integer ([#44](https://github.com/linrongbin16/colorbox.nvim/issues/44)) ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))


### Reverts

* **ci:** revert please-release action to v3 ([#92](https://github.com/linrongbin16/colorbox.nvim/issues/92)) ([8f78495](https://github.com/linrongbin16/colorbox.nvim/commit/8f784950518effa09d69f373b08c52480c4924de))
* **ci:** use please-release ([#85](https://github.com/linrongbin16/colorbox.nvim/issues/85)) ([d4b2eab](https://github.com/linrongbin16/colorbox.nvim/commit/d4b2eabc2d32987d480320402efc10d2e1b8ccf8))

## [1.11.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.10.0...v1.11.0) (2023-12-08)


### Features

* **command:** add `Colorbox` command and provide `reinstall` option ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* **config:** add `cache_dir` option ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **controller:** provide `update` option ([#57](https://github.com/linrongbin16/colorbox.nvim/issues/57)) ([c6338ff](https://github.com/linrongbin16/colorbox.nvim/commit/c6338ff63452e78e6492a83da19e38e5646ce241))
* **filter:** add 'primary' filter ([#21](https://github.com/linrongbin16/colorbox.nvim/issues/21)) ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **fixed interval:** support fixed interval timing and policy ([#59](https://github.com/linrongbin16/colorbox.nvim/issues/59)) ([f0fcd55](https://github.com/linrongbin16/colorbox.nvim/commit/f0fcd552d3b9d9142b101d070034f1f09008a28d))
* **install:** support 'reinstall' on Windows ([#62](https://github.com/linrongbin16/colorbox.nvim/issues/62)) ([9f00c7b](https://github.com/linrongbin16/colorbox.nvim/commit/9f00c7ba8814b8d2d5b1a8000d068a949954a3f7))
* **install:** use `neovim` branch for `lifepillar/vim-solarized8` ([#52](https://github.com/linrongbin16/colorbox.nvim/issues/52)) ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* MPV done ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **policy:** add 'by filetype' policy ([#72](https://github.com/linrongbin16/colorbox.nvim/issues/72)) ([2910a20](https://github.com/linrongbin16/colorbox.nvim/commit/2910a203698851f50b2d9e5754978d7939d3769f))
* **policy:** add 'single' policy ([#70](https://github.com/linrongbin16/colorbox.nvim/issues/70)) ([da537b4](https://github.com/linrongbin16/colorbox.nvim/commit/da537b4aa5aa9f02692d815b4eddce15db2c65dc))
* **policy:** add `reverse_order` policy ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))
* **policy:** play in order ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* update docs ([#19](https://github.com/linrongbin16/colorbox.nvim/issues/19)) ([0e7a564](https://github.com/linrongbin16/colorbox.nvim/commit/0e7a564ef92073a172356acadf183f8f6b7965df))
* **update:** auto-update ([#28](https://github.com/linrongbin16/colorbox.nvim/issues/28)) ([a730726](https://github.com/linrongbin16/colorbox.nvim/commit/a73072677d9ec24006818710531cd3bcc7200529))


### Bug Fixes

* **ci:** fix action-create-tag v1 ([#88](https://github.com/linrongbin16/colorbox.nvim/issues/88)) ([3987942](https://github.com/linrongbin16/colorbox.nvim/commit/3987942a2d488321faf2f886547cf567c6dbf022))
* **ci:** fix infinite PR loop by please-release action ([#82](https://github.com/linrongbin16/colorbox.nvim/issues/82)) ([a984910](https://github.com/linrongbin16/colorbox.nvim/commit/a984910bd59768281f93ef6c69f7f2603d8a7cba))
* **ci:** fix please-release action ([#87](https://github.com/linrongbin16/colorbox.nvim/issues/87)) ([1d93e3e](https://github.com/linrongbin16/colorbox.nvim/commit/1d93e3edd04edf297bba9b50a136f8f7319838f7))
* **ci:** fix release-drafter ([#83](https://github.com/linrongbin16/colorbox.nvim/issues/83)) ([b4ffdb4](https://github.com/linrongbin16/colorbox.nvim/commit/b4ffdb41b942cd9f599ee5a6c613fc7eb539ef00))
* **ci:** fix release-drafter config ([#84](https://github.com/linrongbin16/colorbox.nvim/issues/84)) ([77f8d17](https://github.com/linrongbin16/colorbox.nvim/commit/77f8d175e0847c7c42b0d0354af27b046676cb54))
* **ci:** use please-release v4, remove 'package-name' ([#94](https://github.com/linrongbin16/colorbox.nvim/issues/94)) ([c509f36](https://github.com/linrongbin16/colorbox.nvim/commit/c509f36c2d0f71768787d3d86d0fa526117271fc))
* **filter:** fix 'primary' filter ([91e89c9](https://github.com/linrongbin16/colorbox.nvim/commit/91e89c9c553c3df59e6ebf26bb1038450f883c30))
* **install:** fix NPE in first installation ([#24](https://github.com/linrongbin16/colorbox.nvim/issues/24)) ([2871108](https://github.com/linrongbin16/colorbox.nvim/commit/2871108ef8093da431df47eea57558c6144f862c))
* **install:** fix NPE while installation ([#64](https://github.com/linrongbin16/colorbox.nvim/issues/64)) ([3aa8c2d](https://github.com/linrongbin16/colorbox.nvim/commit/3aa8c2d5fb9a412f643baddea4d0b3840d2092cb))


### Performance Improvements

* **build:** async run to avoid blocking ([#46](https://github.com/linrongbin16/colorbox.nvim/issues/46)) ([814a927](https://github.com/linrongbin16/colorbox.nvim/commit/814a927a14669af4c8d5c86f22cf75488cf408ee))
* **build:** improve git submodules installation speed ([#50](https://github.com/linrongbin16/colorbox.nvim/issues/50)) ([18ce09e](https://github.com/linrongbin16/colorbox.nvim/commit/18ce09eb234a8788cdadcfd56ffff9818fceadb5))
* **ci:** reduce to weekly run ([#30](https://github.com/linrongbin16/colorbox.nvim/issues/30)) ([f4f7603](https://github.com/linrongbin16/colorbox.nvim/commit/f4f7603285ad6a8df83d3312550bbf7ac3dbdda2))
* **ci:** upload luarocks ([#77](https://github.com/linrongbin16/colorbox.nvim/issues/77)) ([b6c7f59](https://github.com/linrongbin16/colorbox.nvim/commit/b6c7f593a005c40c185fb36966d075c799e19239))
* **ci:** upload luarocks ([#91](https://github.com/linrongbin16/colorbox.nvim/issues/91)) ([55be084](https://github.com/linrongbin16/colorbox.nvim/commit/55be08426d0f98a120539185445e187d16987327))
* **collector:** improve colorschemes list ([#66](https://github.com/linrongbin16/colorbox.nvim/issues/66)) ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **colorschemes:** improve COLORSCHEMES list ([#71](https://github.com/linrongbin16/colorbox.nvim/issues/71)) ([5211c28](https://github.com/linrongbin16/colorbox.nvim/commit/5211c282596e37755908908f9e04146b947fc9d3))
* **config:** by default only enable 'primary' colors ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **init:** improve speed via build index when initializing ([#37](https://github.com/linrongbin16/colorbox.nvim/issues/37)) ([8782111](https://github.com/linrongbin16/colorbox.nvim/commit/8782111bdfbe42412a3b3cf00852a9da79f99443))
* **install:** optimize install logs ([#41](https://github.com/linrongbin16/colorbox.nvim/issues/41)) ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **install:** optimize log message ([#75](https://github.com/linrongbin16/colorbox.nvim/issues/75)) ([1ddde8c](https://github.com/linrongbin16/colorbox.nvim/commit/1ddde8c5ebfa4041952757e9d33da799ff039aa6))
* **load:** improve loading data speed ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **policy:** remove 'name' from fixed interval policy ([#68](https://github.com/linrongbin16/colorbox.nvim/issues/68)) ([759d524](https://github.com/linrongbin16/colorbox.nvim/commit/759d524f2e244a2718836b0498a66391f0ab3a14))
* **refactor:** improve code structure ([#33](https://github.com/linrongbin16/colorbox.nvim/issues/33)) ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **shuffle:** better bitwise xor for random integer ([#44](https://github.com/linrongbin16/colorbox.nvim/issues/44)) ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))


### Reverts

* **ci:** revert please-release action to v3 ([#92](https://github.com/linrongbin16/colorbox.nvim/issues/92)) ([8f78495](https://github.com/linrongbin16/colorbox.nvim/commit/8f784950518effa09d69f373b08c52480c4924de))
* **ci:** use please-release ([#85](https://github.com/linrongbin16/colorbox.nvim/issues/85)) ([d4b2eab](https://github.com/linrongbin16/colorbox.nvim/commit/d4b2eabc2d32987d480320402efc10d2e1b8ccf8))

## [1.10.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.9.2...v1.10.0) (2023-12-08)


### Features

* **command:** add `Colorbox` command and provide `reinstall` option ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* **config:** add `cache_dir` option ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **controller:** provide `update` option ([#57](https://github.com/linrongbin16/colorbox.nvim/issues/57)) ([c6338ff](https://github.com/linrongbin16/colorbox.nvim/commit/c6338ff63452e78e6492a83da19e38e5646ce241))
* **filter:** add 'primary' filter ([#21](https://github.com/linrongbin16/colorbox.nvim/issues/21)) ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **fixed interval:** support fixed interval timing and policy ([#59](https://github.com/linrongbin16/colorbox.nvim/issues/59)) ([f0fcd55](https://github.com/linrongbin16/colorbox.nvim/commit/f0fcd552d3b9d9142b101d070034f1f09008a28d))
* **install:** support 'reinstall' on Windows ([#62](https://github.com/linrongbin16/colorbox.nvim/issues/62)) ([9f00c7b](https://github.com/linrongbin16/colorbox.nvim/commit/9f00c7ba8814b8d2d5b1a8000d068a949954a3f7))
* **install:** use `neovim` branch for `lifepillar/vim-solarized8` ([#52](https://github.com/linrongbin16/colorbox.nvim/issues/52)) ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* MPV done ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **policy:** add 'by filetype' policy ([#72](https://github.com/linrongbin16/colorbox.nvim/issues/72)) ([2910a20](https://github.com/linrongbin16/colorbox.nvim/commit/2910a203698851f50b2d9e5754978d7939d3769f))
* **policy:** add 'single' policy ([#70](https://github.com/linrongbin16/colorbox.nvim/issues/70)) ([da537b4](https://github.com/linrongbin16/colorbox.nvim/commit/da537b4aa5aa9f02692d815b4eddce15db2c65dc))
* **policy:** add `reverse_order` policy ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))
* **policy:** play in order ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* update docs ([#19](https://github.com/linrongbin16/colorbox.nvim/issues/19)) ([0e7a564](https://github.com/linrongbin16/colorbox.nvim/commit/0e7a564ef92073a172356acadf183f8f6b7965df))
* **update:** auto-update ([#28](https://github.com/linrongbin16/colorbox.nvim/issues/28)) ([a730726](https://github.com/linrongbin16/colorbox.nvim/commit/a73072677d9ec24006818710531cd3bcc7200529))


### Bug Fixes

* **ci:** fix action-create-tag v1 ([#88](https://github.com/linrongbin16/colorbox.nvim/issues/88)) ([3987942](https://github.com/linrongbin16/colorbox.nvim/commit/3987942a2d488321faf2f886547cf567c6dbf022))
* **ci:** fix infinite PR loop by please-release action ([#82](https://github.com/linrongbin16/colorbox.nvim/issues/82)) ([a984910](https://github.com/linrongbin16/colorbox.nvim/commit/a984910bd59768281f93ef6c69f7f2603d8a7cba))
* **ci:** fix please-release action ([#87](https://github.com/linrongbin16/colorbox.nvim/issues/87)) ([1d93e3e](https://github.com/linrongbin16/colorbox.nvim/commit/1d93e3edd04edf297bba9b50a136f8f7319838f7))
* **ci:** fix release-drafter ([#83](https://github.com/linrongbin16/colorbox.nvim/issues/83)) ([b4ffdb4](https://github.com/linrongbin16/colorbox.nvim/commit/b4ffdb41b942cd9f599ee5a6c613fc7eb539ef00))
* **ci:** fix release-drafter config ([#84](https://github.com/linrongbin16/colorbox.nvim/issues/84)) ([77f8d17](https://github.com/linrongbin16/colorbox.nvim/commit/77f8d175e0847c7c42b0d0354af27b046676cb54))
* **ci:** use please-release v4, remove 'package-name' ([#94](https://github.com/linrongbin16/colorbox.nvim/issues/94)) ([c509f36](https://github.com/linrongbin16/colorbox.nvim/commit/c509f36c2d0f71768787d3d86d0fa526117271fc))
* **filter:** fix 'primary' filter ([91e89c9](https://github.com/linrongbin16/colorbox.nvim/commit/91e89c9c553c3df59e6ebf26bb1038450f883c30))
* **install:** fix NPE in first installation ([#24](https://github.com/linrongbin16/colorbox.nvim/issues/24)) ([2871108](https://github.com/linrongbin16/colorbox.nvim/commit/2871108ef8093da431df47eea57558c6144f862c))
* **install:** fix NPE while installation ([#64](https://github.com/linrongbin16/colorbox.nvim/issues/64)) ([3aa8c2d](https://github.com/linrongbin16/colorbox.nvim/commit/3aa8c2d5fb9a412f643baddea4d0b3840d2092cb))


### Performance Improvements

* **build:** async run to avoid blocking ([#46](https://github.com/linrongbin16/colorbox.nvim/issues/46)) ([814a927](https://github.com/linrongbin16/colorbox.nvim/commit/814a927a14669af4c8d5c86f22cf75488cf408ee))
* **build:** improve git submodules installation speed ([#50](https://github.com/linrongbin16/colorbox.nvim/issues/50)) ([18ce09e](https://github.com/linrongbin16/colorbox.nvim/commit/18ce09eb234a8788cdadcfd56ffff9818fceadb5))
* **ci:** reduce to weekly run ([#30](https://github.com/linrongbin16/colorbox.nvim/issues/30)) ([f4f7603](https://github.com/linrongbin16/colorbox.nvim/commit/f4f7603285ad6a8df83d3312550bbf7ac3dbdda2))
* **ci:** upload luarocks ([#77](https://github.com/linrongbin16/colorbox.nvim/issues/77)) ([b6c7f59](https://github.com/linrongbin16/colorbox.nvim/commit/b6c7f593a005c40c185fb36966d075c799e19239))
* **ci:** upload luarocks ([#91](https://github.com/linrongbin16/colorbox.nvim/issues/91)) ([55be084](https://github.com/linrongbin16/colorbox.nvim/commit/55be08426d0f98a120539185445e187d16987327))
* **collector:** improve colorschemes list ([#66](https://github.com/linrongbin16/colorbox.nvim/issues/66)) ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **colorschemes:** improve COLORSCHEMES list ([#71](https://github.com/linrongbin16/colorbox.nvim/issues/71)) ([5211c28](https://github.com/linrongbin16/colorbox.nvim/commit/5211c282596e37755908908f9e04146b947fc9d3))
* **config:** by default only enable 'primary' colors ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **init:** improve speed via build index when initializing ([#37](https://github.com/linrongbin16/colorbox.nvim/issues/37)) ([8782111](https://github.com/linrongbin16/colorbox.nvim/commit/8782111bdfbe42412a3b3cf00852a9da79f99443))
* **install:** optimize install logs ([#41](https://github.com/linrongbin16/colorbox.nvim/issues/41)) ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **install:** optimize log message ([#75](https://github.com/linrongbin16/colorbox.nvim/issues/75)) ([1ddde8c](https://github.com/linrongbin16/colorbox.nvim/commit/1ddde8c5ebfa4041952757e9d33da799ff039aa6))
* **load:** improve loading data speed ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **policy:** remove 'name' from fixed interval policy ([#68](https://github.com/linrongbin16/colorbox.nvim/issues/68)) ([759d524](https://github.com/linrongbin16/colorbox.nvim/commit/759d524f2e244a2718836b0498a66391f0ab3a14))
* **refactor:** improve code structure ([#33](https://github.com/linrongbin16/colorbox.nvim/issues/33)) ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **shuffle:** better bitwise xor for random integer ([#44](https://github.com/linrongbin16/colorbox.nvim/issues/44)) ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))


### Reverts

* **ci:** revert please-release action to v3 ([#92](https://github.com/linrongbin16/colorbox.nvim/issues/92)) ([8f78495](https://github.com/linrongbin16/colorbox.nvim/commit/8f784950518effa09d69f373b08c52480c4924de))
* **ci:** use please-release ([#85](https://github.com/linrongbin16/colorbox.nvim/issues/85)) ([d4b2eab](https://github.com/linrongbin16/colorbox.nvim/commit/d4b2eabc2d32987d480320402efc10d2e1b8ccf8))

## [1.9.2](https://github.com/linrongbin16/colorbox.nvim/compare/v1.9.1...v1.9.2) (2023-12-08)


### Bug Fixes

* **ci:** fix action-create-tag v1 ([#88](https://github.com/linrongbin16/colorbox.nvim/issues/88)) ([3987942](https://github.com/linrongbin16/colorbox.nvim/commit/3987942a2d488321faf2f886547cf567c6dbf022))
* **ci:** fix infinite PR loop by please-release action ([#82](https://github.com/linrongbin16/colorbox.nvim/issues/82)) ([a984910](https://github.com/linrongbin16/colorbox.nvim/commit/a984910bd59768281f93ef6c69f7f2603d8a7cba))
* **ci:** fix please-release action ([#87](https://github.com/linrongbin16/colorbox.nvim/issues/87)) ([1d93e3e](https://github.com/linrongbin16/colorbox.nvim/commit/1d93e3edd04edf297bba9b50a136f8f7319838f7))
* **ci:** fix release-drafter ([#83](https://github.com/linrongbin16/colorbox.nvim/issues/83)) ([b4ffdb4](https://github.com/linrongbin16/colorbox.nvim/commit/b4ffdb41b942cd9f599ee5a6c613fc7eb539ef00))
* **ci:** fix release-drafter config ([#84](https://github.com/linrongbin16/colorbox.nvim/issues/84)) ([77f8d17](https://github.com/linrongbin16/colorbox.nvim/commit/77f8d175e0847c7c42b0d0354af27b046676cb54))


### Performance Improvements

* **ci:** upload luarocks ([#77](https://github.com/linrongbin16/colorbox.nvim/issues/77)) ([b6c7f59](https://github.com/linrongbin16/colorbox.nvim/commit/b6c7f593a005c40c185fb36966d075c799e19239))


### Reverts

* **ci:** use please-release ([#85](https://github.com/linrongbin16/colorbox.nvim/issues/85)) ([d4b2eab](https://github.com/linrongbin16/colorbox.nvim/commit/d4b2eabc2d32987d480320402efc10d2e1b8ccf8))

## [1.11.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.10.0...v1.11.0) (2023-12-08)


### Features

* **command:** add `Colorbox` command and provide `reinstall` option ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* **config:** add `cache_dir` option ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **controller:** provide `update` option ([#57](https://github.com/linrongbin16/colorbox.nvim/issues/57)) ([c6338ff](https://github.com/linrongbin16/colorbox.nvim/commit/c6338ff63452e78e6492a83da19e38e5646ce241))
* **filter:** add 'primary' filter ([#21](https://github.com/linrongbin16/colorbox.nvim/issues/21)) ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **fixed interval:** support fixed interval timing and policy ([#59](https://github.com/linrongbin16/colorbox.nvim/issues/59)) ([f0fcd55](https://github.com/linrongbin16/colorbox.nvim/commit/f0fcd552d3b9d9142b101d070034f1f09008a28d))
* **install:** support 'reinstall' on Windows ([#62](https://github.com/linrongbin16/colorbox.nvim/issues/62)) ([9f00c7b](https://github.com/linrongbin16/colorbox.nvim/commit/9f00c7ba8814b8d2d5b1a8000d068a949954a3f7))
* **install:** use `neovim` branch for `lifepillar/vim-solarized8` ([#52](https://github.com/linrongbin16/colorbox.nvim/issues/52)) ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* MPV done ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **policy:** add 'by filetype' policy ([#72](https://github.com/linrongbin16/colorbox.nvim/issues/72)) ([2910a20](https://github.com/linrongbin16/colorbox.nvim/commit/2910a203698851f50b2d9e5754978d7939d3769f))
* **policy:** add 'single' policy ([#70](https://github.com/linrongbin16/colorbox.nvim/issues/70)) ([da537b4](https://github.com/linrongbin16/colorbox.nvim/commit/da537b4aa5aa9f02692d815b4eddce15db2c65dc))
* **policy:** add `reverse_order` policy ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))
* **policy:** play in order ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* update docs ([#19](https://github.com/linrongbin16/colorbox.nvim/issues/19)) ([0e7a564](https://github.com/linrongbin16/colorbox.nvim/commit/0e7a564ef92073a172356acadf183f8f6b7965df))
* **update:** auto-update ([#28](https://github.com/linrongbin16/colorbox.nvim/issues/28)) ([a730726](https://github.com/linrongbin16/colorbox.nvim/commit/a73072677d9ec24006818710531cd3bcc7200529))


### Bug Fixes

* **filter:** fix 'primary' filter ([91e89c9](https://github.com/linrongbin16/colorbox.nvim/commit/91e89c9c553c3df59e6ebf26bb1038450f883c30))
* **install:** fix NPE in first installation ([#24](https://github.com/linrongbin16/colorbox.nvim/issues/24)) ([2871108](https://github.com/linrongbin16/colorbox.nvim/commit/2871108ef8093da431df47eea57558c6144f862c))
* **install:** fix NPE while installation ([#64](https://github.com/linrongbin16/colorbox.nvim/issues/64)) ([3aa8c2d](https://github.com/linrongbin16/colorbox.nvim/commit/3aa8c2d5fb9a412f643baddea4d0b3840d2092cb))


### Performance Improvements

* **build:** async run to avoid blocking ([#46](https://github.com/linrongbin16/colorbox.nvim/issues/46)) ([814a927](https://github.com/linrongbin16/colorbox.nvim/commit/814a927a14669af4c8d5c86f22cf75488cf408ee))
* **build:** improve git submodules installation speed ([#50](https://github.com/linrongbin16/colorbox.nvim/issues/50)) ([18ce09e](https://github.com/linrongbin16/colorbox.nvim/commit/18ce09eb234a8788cdadcfd56ffff9818fceadb5))
* **ci:** reduce to weekly run ([#30](https://github.com/linrongbin16/colorbox.nvim/issues/30)) ([f4f7603](https://github.com/linrongbin16/colorbox.nvim/commit/f4f7603285ad6a8df83d3312550bbf7ac3dbdda2))
* **ci:** upload luarocks ([#77](https://github.com/linrongbin16/colorbox.nvim/issues/77)) ([b6c7f59](https://github.com/linrongbin16/colorbox.nvim/commit/b6c7f593a005c40c185fb36966d075c799e19239))
* **collector:** improve colorschemes list ([#66](https://github.com/linrongbin16/colorbox.nvim/issues/66)) ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **colorschemes:** improve COLORSCHEMES list ([#71](https://github.com/linrongbin16/colorbox.nvim/issues/71)) ([5211c28](https://github.com/linrongbin16/colorbox.nvim/commit/5211c282596e37755908908f9e04146b947fc9d3))
* **config:** by default only enable 'primary' colors ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **init:** improve speed via build index when initializing ([#37](https://github.com/linrongbin16/colorbox.nvim/issues/37)) ([8782111](https://github.com/linrongbin16/colorbox.nvim/commit/8782111bdfbe42412a3b3cf00852a9da79f99443))
* **install:** optimize install logs ([#41](https://github.com/linrongbin16/colorbox.nvim/issues/41)) ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **install:** optimize log message ([#75](https://github.com/linrongbin16/colorbox.nvim/issues/75)) ([1ddde8c](https://github.com/linrongbin16/colorbox.nvim/commit/1ddde8c5ebfa4041952757e9d33da799ff039aa6))
* **load:** improve loading data speed ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **policy:** remove 'name' from fixed interval policy ([#68](https://github.com/linrongbin16/colorbox.nvim/issues/68)) ([759d524](https://github.com/linrongbin16/colorbox.nvim/commit/759d524f2e244a2718836b0498a66391f0ab3a14))
* **refactor:** improve code structure ([#33](https://github.com/linrongbin16/colorbox.nvim/issues/33)) ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **shuffle:** better bitwise xor for random integer ([#44](https://github.com/linrongbin16/colorbox.nvim/issues/44)) ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))

## [1.10.0](https://github.com/linrongbin16/colorbox.nvim/compare/v1.9.2...v1.10.0) (2023-12-08)


### Features

* **command:** add `Colorbox` command and provide `reinstall` option ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* **config:** add `cache_dir` option ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **controller:** provide `update` option ([#57](https://github.com/linrongbin16/colorbox.nvim/issues/57)) ([c6338ff](https://github.com/linrongbin16/colorbox.nvim/commit/c6338ff63452e78e6492a83da19e38e5646ce241))
* **filter:** add 'primary' filter ([#21](https://github.com/linrongbin16/colorbox.nvim/issues/21)) ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **fixed interval:** support fixed interval timing and policy ([#59](https://github.com/linrongbin16/colorbox.nvim/issues/59)) ([f0fcd55](https://github.com/linrongbin16/colorbox.nvim/commit/f0fcd552d3b9d9142b101d070034f1f09008a28d))
* **install:** support 'reinstall' on Windows ([#62](https://github.com/linrongbin16/colorbox.nvim/issues/62)) ([9f00c7b](https://github.com/linrongbin16/colorbox.nvim/commit/9f00c7ba8814b8d2d5b1a8000d068a949954a3f7))
* **install:** use `neovim` branch for `lifepillar/vim-solarized8` ([#52](https://github.com/linrongbin16/colorbox.nvim/issues/52)) ([b2a561b](https://github.com/linrongbin16/colorbox.nvim/commit/b2a561b0f85da4836fd3dc136e8593265123617c))
* MPV done ([4c51455](https://github.com/linrongbin16/colorbox.nvim/commit/4c51455a3d0a785e755f47d8facb684aac0bddd0))
* **policy:** add 'by filetype' policy ([#72](https://github.com/linrongbin16/colorbox.nvim/issues/72)) ([2910a20](https://github.com/linrongbin16/colorbox.nvim/commit/2910a203698851f50b2d9e5754978d7939d3769f))
* **policy:** add 'single' policy ([#70](https://github.com/linrongbin16/colorbox.nvim/issues/70)) ([da537b4](https://github.com/linrongbin16/colorbox.nvim/commit/da537b4aa5aa9f02692d815b4eddce15db2c65dc))
* **policy:** add `reverse_order` policy ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))
* **policy:** play in order ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* update docs ([#19](https://github.com/linrongbin16/colorbox.nvim/issues/19)) ([0e7a564](https://github.com/linrongbin16/colorbox.nvim/commit/0e7a564ef92073a172356acadf183f8f6b7965df))
* **update:** auto-update ([#28](https://github.com/linrongbin16/colorbox.nvim/issues/28)) ([a730726](https://github.com/linrongbin16/colorbox.nvim/commit/a73072677d9ec24006818710531cd3bcc7200529))


### Bug Fixes

* **filter:** fix 'primary' filter ([91e89c9](https://github.com/linrongbin16/colorbox.nvim/commit/91e89c9c553c3df59e6ebf26bb1038450f883c30))
* **install:** fix NPE in first installation ([#24](https://github.com/linrongbin16/colorbox.nvim/issues/24)) ([2871108](https://github.com/linrongbin16/colorbox.nvim/commit/2871108ef8093da431df47eea57558c6144f862c))
* **install:** fix NPE while installation ([#64](https://github.com/linrongbin16/colorbox.nvim/issues/64)) ([3aa8c2d](https://github.com/linrongbin16/colorbox.nvim/commit/3aa8c2d5fb9a412f643baddea4d0b3840d2092cb))


### Performance Improvements

* **build:** async run to avoid blocking ([#46](https://github.com/linrongbin16/colorbox.nvim/issues/46)) ([814a927](https://github.com/linrongbin16/colorbox.nvim/commit/814a927a14669af4c8d5c86f22cf75488cf408ee))
* **build:** improve git submodules installation speed ([#50](https://github.com/linrongbin16/colorbox.nvim/issues/50)) ([18ce09e](https://github.com/linrongbin16/colorbox.nvim/commit/18ce09eb234a8788cdadcfd56ffff9818fceadb5))
* **ci:** reduce to weekly run ([#30](https://github.com/linrongbin16/colorbox.nvim/issues/30)) ([f4f7603](https://github.com/linrongbin16/colorbox.nvim/commit/f4f7603285ad6a8df83d3312550bbf7ac3dbdda2))
* **ci:** upload luarocks ([#77](https://github.com/linrongbin16/colorbox.nvim/issues/77)) ([b6c7f59](https://github.com/linrongbin16/colorbox.nvim/commit/b6c7f593a005c40c185fb36966d075c799e19239))
* **collector:** improve colorschemes list ([#66](https://github.com/linrongbin16/colorbox.nvim/issues/66)) ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **colorschemes:** improve COLORSCHEMES list ([#71](https://github.com/linrongbin16/colorbox.nvim/issues/71)) ([5211c28](https://github.com/linrongbin16/colorbox.nvim/commit/5211c282596e37755908908f9e04146b947fc9d3))
* **config:** by default only enable 'primary' colors ([3c4060c](https://github.com/linrongbin16/colorbox.nvim/commit/3c4060c214c3b78783250b7c2e1d0a4b4e6d1e94))
* **init:** improve speed via build index when initializing ([#37](https://github.com/linrongbin16/colorbox.nvim/issues/37)) ([8782111](https://github.com/linrongbin16/colorbox.nvim/commit/8782111bdfbe42412a3b3cf00852a9da79f99443))
* **install:** optimize install logs ([#41](https://github.com/linrongbin16/colorbox.nvim/issues/41)) ([679bc2c](https://github.com/linrongbin16/colorbox.nvim/commit/679bc2c592d4bbaaaecede45505dcd61ca6e2fa7))
* **install:** optimize log message ([#75](https://github.com/linrongbin16/colorbox.nvim/issues/75)) ([1ddde8c](https://github.com/linrongbin16/colorbox.nvim/commit/1ddde8c5ebfa4041952757e9d33da799ff039aa6))
* **load:** improve loading data speed ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **policy:** remove 'name' from fixed interval policy ([#68](https://github.com/linrongbin16/colorbox.nvim/issues/68)) ([759d524](https://github.com/linrongbin16/colorbox.nvim/commit/759d524f2e244a2718836b0498a66391f0ab3a14))
* **refactor:** improve code structure ([#33](https://github.com/linrongbin16/colorbox.nvim/issues/33)) ([9e835a5](https://github.com/linrongbin16/colorbox.nvim/commit/9e835a5fd8293ead9d3c331d671a50036483a0c7))
* **shuffle:** better bitwise xor for random integer ([#44](https://github.com/linrongbin16/colorbox.nvim/issues/44)) ([464f2d8](https://github.com/linrongbin16/colorbox.nvim/commit/464f2d838a869d8c3f2f982f0a0330772ec64ed5))

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
