# jwt-generator

A simple command-line utility to encode JSON Web Tokens (JWT).

## Usage
The Docker container takes two parameters:
- the secret used for signing the token
- the JSON payload

The JSON payload can be provided as an argument:
```sh
docker run --rm orrc/jwt-generator my-shared-secret '{"foo": "bar", "num": 1234}'
```

Or it can be piped in:
```sh
echo '{"foo": "bar", "num": 1234}' | docker run --rm -i orrc/jwt-generator my-shared-secret
```

The JWT is printed to stdout, followed by a newline.


## Credits
This is just a convenient wrapper around a handy [Bash script][0] created by [@williamhaley][1], including some [shell magic][2] by Filipe Fortes.

[0]:https://willhaley.com/blog/generate-jwt-with-bash/
[1]:https://github.com/williamhaley
[2]:https://fortes.com/2019/bash-script-args-and-stdin/
