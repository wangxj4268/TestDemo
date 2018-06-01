# TestDemo
 


```
本文的目的是通过简单的几句命令行，实现自动编译，打包并上传到蒲公英分发给测试人员使用，或者上传到App Store简化上线发布的流程。
```
### 在执行脚本之前需要做的三件事
（如果之前安装过rvm、ruby可直接跳过1，2步，直接进行第三步即可）
#### 1.安装rvm

```
rvm是一个便捷的多版本ruby环境的管理和切换工具 官网：https://rvm.io/
(1).打开终端
输入：curl -sSL https://get.rvm.io | bash -s stable

(2).载入rvm环境
输入：source ~/.rvm/scripts/rvm

(3).修改rvm下载ruby的源，到ruby china的镜像
输入：echo "ruby_url=https://cache.ruby-china.org/pub/ruby" > ~/.rvm/user/db

(4).检查一下是否安装正确
输入：rvm -v
//如果打印出了rvm的版本号，则表示安装正确

```
#### 2.安装ruby

```
(1).列出ruby可安装的版本信息
输入：rvm list known

(2).安装一个ruby版本
输入：rvm install 2.4.0

(3).如果想设置为默认版本，可以用这条命令来完成
输入：rvm use 2.4.0 --default

(4).检查ruby版本是否正确
输入：ruby -v
```
#### 3.安装fir-cli插件

```
输入： gem install fir-cli
```
#### 4.开始做关于脚本的事情了

```
(1).下载脚本
脚本地址为：

(2).将脚本拖入工程目录下
脚本路径：/Users/xxx/Desktop/项目名称/scripts
```
![image](http://m.qpic.cn/psb?/V10Ra4TS1frb6f/S9SY9cIos6C.bXCvLHtJDrqOtVF.Vfayc6G8wpZK1yw!/b/dAoBAAAAAAAA&bo=qgFiAgAAAAADB.k!&rf=viewer_4)
```
(3).配置脚本
1.如果是打development包，则需要配置：xcodebuild_dev_config.sh文件中的以下4项：
- target_name="工程名.xcodeproj" # 有效值 ****.xcodeproj / ****.xcworkspace (cocoapods项目)
- project_name="工程名" # 工程名
- work_type="依据实际情况来填写" # 有效值 project / workspace (cocoapods项目)
- api_token="依据实际情况来填写" # fir token
```
![image](http://m.qpic.cn/psb?/V10Ra4TS1frb6f/8g37Mqunvn.LMABzCgLvXjTwfFT8UJyyoIOvmI8Yp5M!/b/dN4AAAAAAAAA&bo=ygWaAQAAAAADF2Y!&rf=viewer_4)
```
同时还需要配置xcodebuild_dev_config.plist中4个的参数：
- teamId:根据实际的开发者账号来填写
- method：development（枚举值有4个：app-store、ad-hoc、enterprise、development）
- provisioningProfiles中需要配置项目的build id（当初我只配置了profile证书名称而没有填写build id，不知道鼓捣了好久，才在第二天早上才如梦初醒的）
- provisioningProfiles中还需要配置profile文件名称
```
![image](http://m.qpic.cn/psb?/V10Ra4TS1frb6f/v3yjAQOYgMTYkNDjSdwmYEHpDNTEVS7ankHupTphNGo!/b/dPQAAAAAAAAA&bo=oAYkAQAAAAADF7E!&rf=viewer_4)
```
2.如果是打distribution包，参数配置和development中的差不多，只是需要注意plist文件中的profile文件名称需要替换成distribution下的
#如果需要上传到蒲公英上，则需要打开.sh文件中的：
fir p ${out_path}/$project_name.ipa -T $api_token -c 发布release版本

#如果是需要上传到App Store中去，则需要打开.sh文件中的：
# 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
"$altoolPath" --validate-app -f ${out_path}/$project_name.ipa -u xxxxxx@qq.com -p xxxxxx -t ios --output-format xml
"$altoolPath" --upload-app -f ${out_path}/$project_name.ipa -u  xxxxxx@qq.com -p xxxxxx -t ios --output-format xml
```
![image](http://m.qpic.cn/psb?/V10Ra4TS1frb6f/BoBwAOI4pi8*DSjB8udGgvkIdTO6z7eaQZRrwWNmVrM!/b/dOsAAAAAAAAA&bo=AAb0AQAAAAADJ*E!&rf=viewer_4)
```
(4).开始执行脚本
1.首先定位到脚本所在的位置
输入：cd /Users/xxx/Desktop/项目名称/scripts

2.开始执行脚本
#如果是development下的包
输入：bash -l ./xcodebuild_dev_config.sh
#如果是distribution下的包
输入：bash -l ./xcodebuild_dis_config.sh

3.静静的等待终端刷进度，然后就能成功
```
#### 5.题外话：希望踩过的坑别人不要再踩了

```
当初我自己对照着别人的代码实现这个功能时，遇上了很多的问题
1.报错error: archive not found at path '/Users/xxx/Desktop/项目名称/xcode_build_ipa_dev/2018-05-30-16-16-11/XKSDeliver.xcarchive
后来发现是.sh文件中的代码有问题，应该是工程名.xcarchive文件而不应该是XKSDeliver.xcarchive，因为archive出来的文件是$project_name.xcarchive，而exportArchive时查找的是XKSDeliver.xcarchive，所以就会发生找不到文件路径的问题

2.报错error: exportArchive: "xxx.app" requires a provisioning profile
后来发现是plist文件中只配置了三个参数：teamId、method、profile文件名称而忘记了配置build id，等我第二天才发现这个问题所在（ps：这个纯属我自己眼睛有问题了，原楼主的：your build id一直在plist里面，但是我就是没有填...不说了，都是泪）

3.报错Gem::ConflictError...Unable to activate fir-cli-1.6.8, because CFPropertyList-3.0.0 conflicts with...
应该是fir-cli与ruby的版本有冲突了，所以后来我重新安装了rvm、ruby、fir-cli才解决,我最终的版本是：
rvm 版本1.29.3 
ruby版本ruby 2.4.0p0，之前mac上的是2.3.0，我重新安装了ruby，并设置了2.4为默认版
fir-cli版本 1.6.8
```

参考：

MAC_Ruby 安装（https://www.jianshu.com/p/c073e6fc01f5）

fir自动打包脚本--iOS（https://www.jianshu.com/p/af8b929c6624）
