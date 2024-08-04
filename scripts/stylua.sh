#!/bin/sh

stylua --config-path=.stylua.toml --allow-hidden --glob '**/*.lua' .
