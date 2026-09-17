# Licensing notes

Enfold is free software. This file explains what the license covers, what it does not, and
one promise we make to people who ship it through app stores.

## Code: AGPL-3.0-or-later

Everything in this repository is licensed under the GNU Affero General Public License,
version 3 or later, except where a directory carries its own license file (see below).
The full text is in [`LICENSE`](./LICENSE).

Copyright (C) 2026 Raul Glodean and the Enfold contributors.

In plain words: you may use, study, change and redistribute the app and the API. If you run
a modified version for other people, over a network or through an app store, you must offer
them the complete source of your version under the same license.

## App store covenant

App stores such as Apple's App Store impose terms that can conflict with parts of the GPL
family, in particular the freedom to redistribute the installed binary. Following the
example set by Nextcloud, we, the copyright holders of Enfold, make this commitment:

> We will not pursue any license violation that results solely from the conflict between
> the terms of the GNU AGPL version 3 and the terms of the Apple App Store, Google Play or
> a comparable app distribution service, as long as the source code of the distributed
> version is made available under the AGPL.

Contributors agree to this covenant for their contributions by submitting them (see
[`CONTRIBUTING.md`](./CONTRIBUTING.md)).

## What is not under the AGPL

| Path | License | Why |
|---|---|---|
| `content/` | [CC BY-NC-ND 4.0](./content/LICENSE.md) | Clinician-reviewed health education. Readable for transparency, not for reuse in other products. |
| `assets/brand/`, `landing/public/images/`, `assets/illustrations/`, app icons and launch images | All rights reserved, see [`TRADEMARK.md`](./TRADEMARK.md) | The Enfold name, logo and illustrations identify this project. Forks must replace them. |
| `assets/fonts/` | SIL Open Font License | Nunito and Fraunces, license texts alongside the files. |

The illustrations under `assets/illustrations/` and `landing/public/images/` are compositions
made from Adobe Stock assets licensed to the project. They are included so the app builds
and looks like the published app, but they are not licensed to you for any other use.

## Third-party code

Flutter packages and Python dependencies keep their own licenses. The app shows them in
Settings under "Licenses" via Flutter's license registry.
