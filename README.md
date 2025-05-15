Attempt to reproduce https://github.com/mtrudel/bandit/issues/490

```console
$ fly launch # please see fly.toml.example
$ fly scale count 1 -r den # primary
$ fly scale count 1 -r lhr # replica which I'm closer to
$ fly logs
```
```console
$ curl -X POST https://bandit-fly.fly.dev -d "some data" --limit-rate 5B
Hey from Bandit, Fly!

```

Logs:
```
2025-05-15T21:24:38Z app[73d8d4555f9389] lhr [info]21:24:38.431 [info]  replaying request to primary region: den
2025-05-15T21:24:38Z app[e82d757f034568] den [info]21:24:38.490 [debug] fly_region=cdg  POST /
2025-05-15T21:24:39Z app[e82d757f034568] den [info]21:24:39.311 [debug] fly_region=cdg  Sent 200 in 820ms
2025-05-15T21:25:38Z app[73d8d4555f9389] lhr [info]21:25:38.433 [error]  ** (Bandit.HTTPError) Body read timeout
```
