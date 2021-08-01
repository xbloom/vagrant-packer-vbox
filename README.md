# vagrant-packer-vbox

### what
- packer build
- virtualbox
- VBoxGuestAdditions
- rocky 8.4
- 交大源(sjtug)

### How
修改 rocky-8.4-x86_64-vbox.json 中 mirror为 本地 iso文件地址， 也可以是url

本地需要安装 vritualbox，packer， vagrant
```shell
brew install vagrant packer virtualbox
```
执行
```shell
make all
```
