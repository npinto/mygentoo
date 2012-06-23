ifndef INIT_MK
INIT_MK=init.mk

REAL_HOME:=$(shell readlink -f ~/)
ifeq (${HOME}, ${REAL_HOME})
  EMERGE:=emerge
else
  EMERGE:=cd ${REAL_HOME} && emerge
endif


endif