#!/bin/sh

#使用方法：bash -l ./xcodebuild_dis_config.sh

target_name="请按实际填写(如：TestDemo.xcodeproj)" # 有效值 ****.xcodeproj / ****.xcworkspace (cocoapods项目)
project_name="请按实际填写(如：TestDemo)" # 工程名
work_type="请按实际填写（如：project)" # 有效值 project / workspace (cocoapods项目)
api_token="请按实际填写（如：xxxdddxxxx)" # fir token

sctipt_path=$(cd `dirname $0`; pwd)
echo sctipt_path=${sctipt_path}
work_path=${sctipt_path}/..
rm -rf ${work_path}/build

#cd ../
#pod install --no-repo-update
#cd ${sctipt_path}


out_sub_path=`date "+%Y-%m-%d-%H-%M-%S"`
out_base_path="xcode_build_ipa_dis"
out_path=${work_path}/${out_base_path}/${out_sub_path}
mkdir -p ${out_path}


if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
    source $HOME/.rvm/scripts/rvm
    rvm use system
fi

xcodebuild -$work_type ${work_path}/$target_name -scheme $project_name -configuration Release -sdk iphoneos clean
xcodebuild archive -$work_type ${work_path}/$target_name -scheme $project_name -configuration Release -archivePath ${out_path}/$project_name.xcarchive

xcodebuild -exportArchive -archivePath ${out_path}/$project_name.xcarchive -exportPath ${out_path} -exportOptionsPlist ${sctipt_path}/xcodebuild_dis_config.plist

echo ${out_path}/$project_name.ipa

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
    source ~/.rvm/scripts/rvm
    rvm use default
fi

#【第一种】：这里是直接上传到App Store中去的，看个人需求决定是否需要执行下面这段代码
#验证并上传到App Store
# 将-u 后面的XXXX替换成自己的AppleID的账号，-p后面的XXXX替换成自己的密码
#altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
#"$altoolPath" --validate-app -f ${out_path}/$project_name.ipa -u xxxx@qq.com -p xxxx -t ios --output-format xml
#"$altoolPath" --upload-app -f ${out_path}/$project_name.ipa -u  xxxx@qq.com -p xxxx -t ios --output-format xml

#【第二种】：这里是直接打包到蒲公英上的，看个人需求决定是否需要执行下面这段代码
fir p ${out_path}/$project_name.ipa -T $api_token -c 发布release版本

exit 0
