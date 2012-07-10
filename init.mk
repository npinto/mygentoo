ifndef INIT_MK
INIT_MK=init.mk

SHELL=${EPREFIX}/bin/bash

REAL_HOME:=$(shell readlink -f ~/)
ifeq (${HOME}, ${REAL_HOME})
  EMERGE:=emerge
else
  EMERGE:=cd ${REAL_HOME} && emerge
endif


endif
