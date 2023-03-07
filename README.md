# ohmjs.org

This repo contains the source for [ohmjs.org][]. It's built using [Docusaurus][], and hosted on GitHub pages.

Historically, the Ohm web site was at [ohmlang.github.io][]; later we started using [ohmjs.org][] as [custom domain][]. In theory, it should be possible to host the site itself elsewhere, as long as we don't remove the [CNAME in ohmlang.github.io][cname].

[ohmjs.org]: https://ohmjs.org
[Docusaurus]: https://docusaurus.io/
[ohmlang.github.io]: https://ohmlang.github.io
[custom domain]: https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site#about-custom-domain-configuration
[cname]: https://github.com/ohmlang/ohmlang.github.io/blob/main/static/CNAME

## Development

Prerequisites:

- [Node.js](https://nodejs.org/)
- [Yarn](https://classic.yarnpkg.com/)

### Installation

```
$ yarn
```

### Local Development

```
$ yarn start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

### Updating docs

The main Ohm repo ([ohmjs/ohm][]) is the canonical source for most of the documentation here. After changes are made in that repo, they can be propagated to this one:

- Make sure you have a clone [ohmjs/ohm] in a sibling directory (i.e., `../ohm`, relatiive to this README).
- Run `scripts/updateDocs.sh` to copy the docs into this repo
- Ensure there are no build errors from `yarn start`
- Commit and [deploy](#deployment)

See [Writing documentation](https://ohmjs.org/docs/contributor-guide#writing-documentation) in the Contributor Guide for some gotchas to watch out for. Note that the docs are written as [GitHub-flavored Markdown (GFM)][gfm], while Docusaurus uses [MDX v1](https://v1.mdxjs.com/). While most things should "just work", there are some subtle incompatibilities. Use `scripts/escapeMdx.mjs` for anything that needs to be rewritten.

[ohmjs/ohm]: https://github.com/ohmjs/ohm
[gfm]: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax

### Build

```
$ yarn build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

### Deployment

The site is deployed to the `gh-pages` branch of [ohmlang/ohmlang.github.io](https://github.com/ohmlang/ohmlang.github.io). In order to deploy, you need write privileges to that repository.

```
$ yarn deploy
```
