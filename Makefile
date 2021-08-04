box :=rocky-8.4-x86_64-vbox
$(info box name is $(box))

ifdef debug
  release :=
else
  release :=--release
endif

vagrant-init:
	vagrant plugin install vagrant-vbguest vagrant-share


build:
	PACKER_LOG=1 packer build rocky-8.4-x86_64-vbox.json

run:
	vagrant destroy
	vagrant box remove -f $(box) || true
	vagrant box add -f boxes/$(box).box --name $(box)
	vagrant up


all: build run

.DEFAULT_GOAL := all