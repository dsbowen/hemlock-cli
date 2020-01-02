# Hemlock-CLI

Hemlock-CLI is a command line tool for the [Hemlock](dsbowen.github.io/hemlock) survey creation package.

## Basic use

The following commands will initialize a new Hemlock project, deploy the survey in a 'production-lite' environment, then scale it to a full production environment.

```
$ hlk init my-project
$ hlk deploy my-app
$ hlk production
```

Other commands allow programmers to:
1. Run a Hemlock app or shell locally.
2. Run the Hemlock debugging tool in local and production environments.
3. Create and associate Google storage with a Hemlock project.
4. Run a local Redis Queue for a Hemlock app.

## Documentation

You can find the latest documentation at [dsbowen.github.io/hemlock](dsbowen.github.io/hemlock]).

## License

Hemlock was created first and foremost as a free, open-source tool for academic and non-profit research. I aim to obtain a license permitting unlimited free use for legitimate academic and non-profit research by February 2020.

Until I obtain this license, I require that all Hemlock users obtain written permission from its copyright holder, Dillon Bowen. Any use without written permission from the copyright holder is strictly prohibited.