application playground

source "src"
source "app" if !test
source "tests" if test

import cstd
import std
import html_cbi
import css_cbi
import json
import page
import net
import http
import fs

import test if test
import test_env if test