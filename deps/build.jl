# install NodeJS modules
using NodeJS

run(Cmd(`$(npm_cmd()) install --scripts-prepend-node-path=true --production --no-package-lock --no-optional mathjax-node-cli`, dir=@__DIR__))
