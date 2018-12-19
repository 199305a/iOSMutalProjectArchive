# !/bin/bash

#
# 联系方式 :
# BY
# qiubaiying@gamil.com
# GitHub: https://github.com/qiubaiying/iOSAutoArchiveScript
# 原作者:jkpang GitHub: https://github.com/jkpang

#
# =============================== 该脚本在最新的 Ruby 2.4.0 下运行会出错 ====================
# =============================== 使用前请先切换旧的 Ruby 版本 =============================
# https://github.com/jkpang/PPAutoPackageScript/issues/1


# 使用方法:
# step1 : 将iOSAutoArchiveScript整个文件夹拖入到项目主目录,项目主目录,项目主目录~~~(重要的事情说3遍!😊😊😊)
# step2 : 打开iOSAutoArchiveScript.sh文件,修改 "项目自定义部分" 配置好项目参数
# step3 : 打开终端, cd到iOSAutoArchiveScript文件夹 (ps:在终端中先输入cd ,直接拖入iOSAutoArchiveScript文件夹,回车)
# step4 : 输入 sh iOSAutoArchiveScript.sh 命令,回车,开始执行此打包脚本

# ===============================项目自定义部分(自定义好下列参数后再执行该脚本)============================= #
# 计时
SECONDS=0
# 是否编译工作空间 (例:若是用Cocopods管理的.xcworkspace项目,赋值true;用Xcode默认创建的.xcodeproj,赋值false)
is_workspace="true"
# 指定项目的scheme名称


# (注意: 因为shell定义变量时,=号两边不能留空格,若scheme_name与info_plist_name有空格,脚本运行会失败,暂时还没有解决方法,知道的还请指教!)
scheme_name="ChaoDai"
# 工程中Target对应的配置plist文件名称, Xcode默认的配置文件为Info.plist
info_plist_name="Info"
# 指定要打包编译的方式 : Release,Debug，或者自定义的编译方式
build_configuration="AdHoc"
#项目路径，根据你的配置进行修改
#projectDir="/Users/cuihao/Documents/HX_COMPANY/app-ios"

#项目路径，根据你的配置进行修改
project="/Users/cuihao/Documents/HX_COMPANY/app-ios/ChaoDai"
# 打包生成路径 需修改
ipaPath="/Users/cuihao/Desktop/shell"
# sh路径 需修改
SHPath="/Users/cuihao/Desktop/OCTestDemo/iOSAutoArchiveScript"

#CER证书
DEVELOP_CER="935D60DBADF0C9FEA8BEC8B6D04D5607483B8DB4"

#app名称
app_names=("dummy" "${scheme_name}one" "${scheme_name}two" "${scheme_name}three" "${scheme_name}four" "${scheme_name}five") #dummy表示忽略第一个


#app图标资源路径
app_icons_dir="./$target_name/appIcons"

#bundle id每个app是不一样的，前缀
app_bundle_id_prefix=("dummy" "com.ttsd.one" "com.ttsd.two" "com.ttsd.three" "com.ttsd.four" "com.ttsd.five")

#bundle id每个app是不一样的，前缀
app_entitlements=("dummy" "embeddedone" "embeddedtwo" "embeddedthree" "embeddedfour" "embeddedfive")


#app个数
app_num=${#app_names[@]}




# ===============================项目上传部分============================= #
# 上传到fir <https://fir.im>，
# 需要先安装fir的命令行工具 
# gem install fir-cli
# 是否上传到fir，是true 否false
is_fir="false"
# 在 fir 上的API Token
fir_token="you_fir_Token"

# ===============================自动打包部分(无特殊情况不用修改)============================= #

# 导出ipa所需要的plist文件路径 (默认为AdHocExportOptionsPlist.plist)
ExportOptionsPlistPath="./iOSAutoArchiveScript/AdHocExportOptionsPlist.plist"


ExportOptionsPlist="./iOSAutoArchiveScript/ExportOptions.plist"


# 返回上一级目录,进入项目工程目录
cd ..

# 获取项目名称
#project_name= $scheme_name
project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`
# 获取版本号,内部版本号,bundleID
InfoPlistPath="$project_name/$info_plist_name.plist"
bundle_version=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $InfoPlistPath`
bundle_build_version=`/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" $InfoPlistPath`
bundle_identifier=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $InfoPlistPath`


# 指定输出ipa路径
export_path=~/AutoArchive/$scheme_name-IPA
# 指定输出归档文件地址
export_archive_path="$export_path/$scheme_name.xcarchive"

SOURCE_ARCHIVE="$export_archive_path"

# 指定输出ipa地址
export_ipa_path="$export_path"
# 指定输出ipa名称 : scheme_name + bundle_version
ipa_name="$scheme_name-v$bundle_version"


# AdHoc,AppStore,Enterprise三种打包方式的区别: http://blog.csdn.net/lwjok2007/article/details/46379945
echo "================请选择打包方式(输入序号,按回车即可)================"
echo "                1 AdHoc       内测        "
echo "                2 AppStore    上架        "
echo "                3 Enterprise  企业        "
echo "                4 Exit        退出        "
echo "================请选择打包方式(输入序号,按回车即可)================"
# 读取用户输入并存到变量里
read parameter
sleep 0.5
method="$parameter"

# 判读用户是否有输入
if [ -n "$method" ]
then
    if [ "$method" = "1" ] ; then
    ExportOptionsPlistPath="./iOSAutoArchiveScript/AdHocExportOptionsPlist.plist"
    elif [ "$method" = "2" ] ; then
    ExportOptionsPlistPath="./iOSAutoArchiveScript/AppStoreExportOptionsPlist.plist"
    elif [ "$method" = "3" ] ; then
    ExportOptionsPlistPath="./iOSAutoArchiveScript/EnterpriseExportOptionsPlist.plist"
    elif [ "$method" = "4" ] ; then
    echo "退出！"
    exit 1
    else
    echo "输入的参数无效，请重新选择!!!"
    exit 1
    fi
fi




##modify project settings 执行Xcodeproj脚本修改工程配置文件
#ruby modifyProj.rb $app_name $app_bundle_id $app_bundle_version

#defaults write ${ipaPath}/Payload/${schemeName}.app/info.plist "CFBundleName" $appName

#defaults write ${ipaPath}/Payload/${schemeName}.app/info.plist "Channel" $appDownloadName

echo "**************************删除旧编译文件与ipa...*********************************"

rm -rf $ipaPath/
rm -rf ~/AutoArchive/$scheme_name-IPA/
# 删除旧.xcarchive文件
rm -rf ~/AutoArchive/$scheme_name-IPA/$scheme_name.xcarchive
# 删除旧.xcarchive文件
rm -rf ~/AutoArchive/$scheme_name-IPA/$ipa_name.ipa

echo "**************************开始编译代码...*********************************"
# 指定输出文件目录不存在则创建
if [ -d "$export_path" ] ; then
echo $export_path
else
mkdir -pv $export_path
fi

# 判断编译的项目类型是workspace还是project
if $is_workspace ; then
# 编译前清理工程
xcodebuild clean -workspace ${project}.xcworkspace \
                 -scheme ${scheme_name} \
                 -configuration ${build_configuration}

xcodebuild archive -workspace ${project}.xcworkspace \
                   -scheme ${scheme_name} \
                   -configuration ${build_configuration} \
                   -archivePath ${export_archive_path}
else
# 编译前清理工程



xcodebuild clean -project ${project}.xcodeproj \
                 -scheme ${scheme_name} \
                 -configuration ${build_configuration}

xcodebuild archive -project ${project}.xcodeproj \
                   -scheme ${scheme_name} \
                   -configuration ${build_configuration} \
                   -archivePath ${export_archive_path}
fi

#  检查是否构建成功
#  xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if [ -d "$export_archive_path" ] ; then
echo " ✅  ✅  ✅  ✅  ✅  ✅  编译成功  ✅  ✅  ✅  ✅  ✅  ✅  "
else
echo " ❌  ❌  ❌  ❌  ❌  ❌  编译失败  ❌  ❌  ❌  ❌  ❌  ❌  "
exit 1
fi


echo "**************************开始导出ipa文件....*********************************"
# Xcode9需要加上 -allowProvisioningUpdates
# 详情看:https://github.com/fastlane/fastlane/issues/9589
xcodebuild  -exportArchive \
-archivePath ${export_archive_path} \
-exportPath ${export_ipa_path} \
-exportOptionsPlist ${ExportOptionsPlist} \
-allowProvisioningUpdates
# 修改ipa文件名称
#mv $export_ipa_path/$scheme_name.ipa $export_ipa_path/$app_name.ipa

# 检查文件是否存在
if [ -f "$export_ipa_path/$scheme_name.ipa" ] ; then
echo "🎉  🎉  🎉  🎉  🎉  🎉  ${ipa_name} 打包成功! 🎉  🎉  🎉  🎉  🎉  🎉  "
#open $export_path
else
echo "❌  ❌  ❌  ❌  ❌  ❌  ${ipa_name} 打包失败! ❌  ❌  ❌  ❌  ❌  ❌  "
exit 1
fi


for (( i = 1 ; $i < ${app_num}; i++ )) ; do

SOURCE_IPA=$export_ipa_path/$scheme_name.ipa

app_name=${app_names[$i]}
app_bundle_id=${app_bundle_id_prefix[$i]}

#IPA解压
TEMP_DIR="$export_ipa_path/tmp"
mkdir "$TEMP_DIR"
unzip -qo "$SOURCE_IPA" -d "$TEMP_DIR"

defaults write $TEMP_DIR/Payload/$scheme_name.app/info.plist "CFBundleIdentifier" $app_bundle_id

#拷贝描述文件
MOBILEPROV_NAME="embedded.mobileprovision"
APPLICATION=$(ls $TEMP_DIR/Payload/)
#cp "$MOBILEPROV" "$TEMP_DIR/Payload/$APPLICATION/$MOBILEPROV_NAME"
cp "$SHPath/${app_entitlements[$i]}.mobileprovision" "$TEMP_DIR/Payload/$scheme_name.app/$MOBILEPROV_NAME"


echo "$SHPath${app_entitlements[$i]}.mobileprovision" "$TEMP_DIR/Payload/$scheme_name.app/$MOBILEPROV_NAME"
rm -rf "$TEMP_DIR/Payload/$scheme_name.app/_CodeSignature"


#扫描IPA里所有需要重签名的组件，包括app/appex/framework/dylib
RESIGN_FILES="resign_file.txt"
echo "Resigning with certificate: $DEVELOP_CER" >&2
find -d $TEMP_DIR  \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.dylib" \) > "$RESIGN_FILES"

#获取描述文件里的授权机制(entitlements.plist)
RESIGN_ENTITLEMWNTS_FULL="entitlements_full.plist"
RESIGN_ENTITLEMWNTS="entitlements.plist"
security cms -D -i "$TEMP_DIR/Payload/$scheme_name.app/$MOBILEPROV_NAME" > "$RESIGN_ENTITLEMWNTS_FULL"
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' "$RESIGN_ENTITLEMWNTS_FULL" > "$RESIGN_ENTITLEMWNTS"

#签名
while IFS='' read -r line || [[ -n "$line" ]]; do
echo "$line"
/usr/bin/codesign --continue -f -s "$DEVELOP_CER" --entitlements "$RESIGN_ENTITLEMWNTS"  "$line"
done < "$RESIGN_FILES"

#压缩为IPA
echo "Creating the Signed IPA"
cd $TEMP_DIR
zip -qry $TEMP_DIR.ipa *
cd ..
#mv $TEMP_DIR.ipa "$DESTINATION_IPA"
mv $TEMP_DIR.ipa $export_ipa_path/$app_name.ipa


# 检查重签名是否存在
if [ -f "$export_ipa_path/$app_name.ipa" ] ; then
echo "🎉  🎉✅  🎉  🎉✅  🎉  🎉  ${ipa_name} 重签名成功! 🎉  🎉 ✅ 🎉  🎉  ✅🎉  🎉  "
#open $export_path
else
echo "❌  ❌  ❌  ❌  ❌  ❌  ${ipa_name} 重签名失败! ❌  ❌  ❌  ❌  ❌  ❌  "
exit 1
fi


done


rm -rf "$TEMP_DIR"
rm "$RESIGN_FILES"
rm "$RESIGN_ENTITLEMWNTS"
rm "$RESIGN_ENTITLEMWNTS_FULL"
rm "Packaging.log"
rm "DistributionSummary.plist"
rm "ExportOptions.plist"
rm -rf "$scheme_name.xcarchive"
rm "$scheme_name.ipa"
#open $export_path

cp -r $export_ipa_path/ $ipaPath
echo "✅✅✅✅✅导出ipa到文件夹$ipaPath"
open $ipaPath

#for (( i = 1 ; $i < ${app_num}; i++ )) ; do
#echo "--------Started: " $i
#
##rm -rf ~/AutoArchive/$scheme_name-IPA/DistributionSummary.plist
##rm -rf ~/AutoArchive/$scheme_name-IPA/ExportOptions.plist
#
##app info要在工程中修改的信息
#app_name=${app_names[$i]}
#app_bundle_id=${app_bundle_id_prefix[$i]}
#
#
#DEVELOP_MOBILEPROV= "/Users/cuihao/Desktop/OCTestDemo/iOSAutoArchiveScript/${app_entitlements[$i]}.mobileprovision"
#
##DESTINATION_ARCHIVE="export_archive_path"
#
#defaults write ${export_archive_path}/Products/Applications/$scheme_name.app/info.plist "CFBundleIdentifier" $app_bundle_id
##xattr -cr ${export_archive_path}/Products/Applications/$scheme_name.app
##codesign -f -s "935D60DBADF0C9FEA8BEC8B6D04D5607483B8DB4"  --entitlements $Entitlements ${export_archive_path}/Products/Applications/$scheme_name.app
#
##APP做备份
#TEMP_ARCHIVE=$SOURCE_ARCHIVE
##cp -r "$SOURCE_ARCHIVE" "$TEMP_ARCHIVE"
#
##TEMP_ARCHIVE="$SOURCE_ARCHIVE"
#
##cp -r "$SOURCE_ARCHIVE" "$TEMP_ARCHIVE"
#
##拷贝描述文件
#MOBILEPROV_NAME="embedded.mobileprovision"
#
##计算Archive包里App的路径
#APP_NAME=$(ls $TEMP_ARCHIVE/Products/Applications/)
#SOURCE_APP="$TEMP_ARCHIVE/Products/Applications/$APP_NAME"
#
#echo "$APP_NAME" "$SOURCE_APP" "$TEMP_ARCHIVE"
#
#echo "证书地址：$SHPath${app_entitlements[$i]}.mobileprovision"
#echo "$DEVELOP_MOBILEPROV" "$SOURCE_APP/$MOBILEPROV_NAME"
#
##拷贝描述文件
#cp "$SHPath${app_entitlements[$i]}.mobileprovision" "$SOURCE_APP/$MOBILEPROV_NAME"
#
##扫描APP里所有需要重签名的组件，包括app/appex/framework/dylib
#RESIGN_FILES="resign_file.txt"
#echo "Resigning with certificate: $DEVELOP_CER" >&2
#find -d $TEMP_ARCHIVE  \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.dylib" \) > "$RESIGN_FILES"
#
##获取描述文件里的授权机制(entitlements.plist)
#RESIGN_ENTITLEMWNTS_FULL="entitlements_full.plist"
#RESIGN_ENTITLEMWNTS="entitlements.plist"
#security cms -D -i "$SOURCE_APP/$MOBILEPROV_NAME" > "$RESIGN_ENTITLEMWNTS_FULL"
#/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' "$RESIGN_ENTITLEMWNTS_FULL" > "$RESIGN_ENTITLEMWNTS"
#
##签名
#while IFS='' read -r line || [[ -n "$line" ]]; do
#echo "$line"
#/usr/bin/codesign --continue -f -s "$DEVELOP_CER" --entitlements "$RESIGN_ENTITLEMWNTS"  "$line"
##/usr/bin/codesign --continue -f -s "$DEVELOP_CER" "$line"
#done < "$RESIGN_FILES"
#
#echo "Creating the Signed Archive"





done

# 输出打包总用时
echo "打包总用时: ${SECONDS}s ~~~~~~~~~~~~~~~~"

# 上传
if $is_fir ; then
echo "**************************开始上传ipa文件....*********************************"
fir publish "$export_ipa_path/$ipa_name.ipa" -T ${fir_token}
echo "fir publish "$export_ipa_path/$ipa_name.ipa" -T ${fir_token}"
echo "总计用时:${SECONDS}"
else
exit 1
fi
