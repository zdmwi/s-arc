#!/bin/bash 

for file in src/*puml; do
    name=${file##*/}
    base=${name%.puml}

    fileContent=$(cat src/$name)
    
    mdHeader="\`\`\`plantuml"
    mdFooter="\`\`\`"

    printf "%s\n%s\n%s" $mdHeader "$fileContent" $mdFooter > diagrams/$base.md
done
