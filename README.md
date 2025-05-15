Attempt to reproduce https://github.com/mtrudel/bandit/issues/490

```console
$ fly launch
$ fly scale count 1 -r den # primary
$ fly scale count 1 -r lhr # replica which I'm closer to
$ fly logs
$ curl https://bandit-fly.fly.dev
```
