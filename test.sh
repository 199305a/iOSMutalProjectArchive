# !/bin/bash


app_entitlements=("dummy" "embeddedone" "embeddedtwo" "embeddedthree" "embeddedfour" "embeddedfive")

# sh路径 需修改
SHPath="./iOSAutoArchiveScript/"

echo "$SHPath"

for (( i = 1 ; $i < ${#app_entitlements[@]}; i++ )) ;
do




echo ${app_entitlements[$i]}

MYdevelop = ${app_entitlements[$i]}
echo $SHPath
echo $MYdevelop
#develop ="${app_entitlements[$i]}.mobileprovision"
#DEVELOP_MOBILEPROV= "$SHPath$develop"
#echo "$develop"

#echo "$DEVELOP_MOBILEPROV"
done
