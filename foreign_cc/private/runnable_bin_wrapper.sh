#!/bin/bash

find

# have to --enable_runfiles

# How to get dependency DLLs here? The make_variant rule needs to have them as outputs? or runfiles?
#TODO perhaps make a helper macro in rules_foreign_cc for running binaries produced by rules_foreign_cc, which creates a sh_binary