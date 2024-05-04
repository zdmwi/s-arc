#!/bin/bash 

for file in src/*mmd; do
    name=${file##*/}
    base=${name%.mmd}

    fileContent=$(cat src/$name)
    
    mdHeader="\`\`\`mermaid"
    mdFooter="\`\`\`"

    printf "%s\n%s\n%s" $mdHeader "$fileContent" $mdFooter > diagrams/$base.md
done
