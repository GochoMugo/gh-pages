# gh-pages

> Get started with [Github Pages][pages] in a faster way


## introduction:

This is a [msu][msu] module that aids you setting up your [Github Pages][pages].
It basically sets up a bunch of shell scripts that will be executed
on commit by [Travis CI][travis].


## prerequisites:

* [msu][msu]
* signed up at [Travis CI][travis]


## installation:

```bash
⇒ msu install gh:GochoMugo/gh-pages
⇒ gh-pages recommended-templates # optional but useful
```


## usage:

Initialize your repository by running:

```bash
$ gh-pages init
```

It will prompt and advise you accordingly, in the process of setting up.


## help information:

```bash
⇒ gh-pages help
```


## templates:

This module is useless on its own as it does **not** include logic
for building sites in any framework. However, some templates are
available:

* [jekyll](https://github.com/GochoMugo/gh-pages-jekyll)
* *send a PR to have yours added here*


## license:

**The MIT License (MIT)**

Copyright (c) 2015-2016 GochoMugo (www.gmugo.in)


[msu]:https://github.com/GochoMugo/msu
[travis]:https://travis-ci.org
[pages]:https://pages.github.com
