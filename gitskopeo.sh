args=($@)
inline=0

options=(
    -s #specific files 
)

if [[ ! -z $(echo -e "${args[-1]}" | grep -o "https://.*.git") ]]; then 
    if [[ ! -z $(echo -e "${args[-2]}" | grep -o "https://.*.git") ]]; then 
        from="${args[-2]}";
        to="${args[-1]}";
        inline=2
    else
        from="${args[-1]}";
        inline=1
    fi
fi

if [[ -z $from && -e details.txt ]]; then from="$(grep -oP '(?<=from).*' details.txt | tr = ' ' | sed 's/ //g' )"; fi
if [[ -z $to && -e details.txt ]]; then to="$(grep -oP '(?<=to).*' details.txt | tr = ' ' | sed 's/ //g' )"; fi

if [[ -z $from ]]; then read -p "from repo url : " form; fi
if [[ -z $to ]]; then read -p "To repo url : " to; fi

echo from = $from
echo to = $to

tempdir=$(openssl rand -hex 3)

mkdir $tempdir
cd $tempdir

git clone "$from"
git clone "$to"

fromf=$(echo -e $from | grep -oP '(?<=/).*?(?=.git)'|cut -d "/" -f "3")
tof=$(echo -e $to | grep -oP '(?<=/).*?(?=.git)'|cut -d "/" -f "3")

mv $fromf/* $tof

fromfpwd=$(cd $fromf; pwd; cd ..)
echo $(pwd)
echo $fromfpwd
cd $tof

hasfiles=false

checkoption(){
    if [[ "${args[@]}" =~ "-s" ]]; then

        for i in ${!args[@]};
        do
            if [[ ${args[i]} == "-s" ]]; then
                files=(${args[@]:$i:((${#args[i]}-$inline))})
                mv -t $fromfpwd ${files[@]}
                return
            fi
        done
    else
        mv $fromf/* $tof
    fi
}


checkoption

git add .
git add .
git commit -m "synced from $from"
git push origin

cd ../..
rm -rf $tempdir