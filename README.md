# Dotfiles

My dotfiles.
## Setup Debian/Ubuntu
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ryqdev/dotfiles/refs/heads/main/bootstrap.sh)"

```

## Append in the LLM init file
```shell
curl -fsSL 'https://raw.githubusercontent.com/ryqdev/dotfiles/refs/heads/main/LLM.md' | tee -a CLAUDE.md AGENTS.md >/dev/null
```

## Setup in AWS EC2
```shell
curl -fsSL https://raw.githubusercontent.com/ryqdev/dotfiles/main/bootstrap_ec2.sh | bash
```
