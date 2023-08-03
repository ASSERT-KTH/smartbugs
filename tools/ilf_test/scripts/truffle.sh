#!/bin/bash
FILENAME="$1"

file_name="2_deploy_contracts.js"
file_content="var contract = artifacts.require(\"$FILENAME\");\nmodule.exports = function(deployer) {\n  deployer.deploy(contract);\n};"

echo -e "$file_content" > "migrations/$file_name"

main_content="\
    development: {\
        host: \"127.0.0.1\",\
        port: 8545,\
        network_id: \"*\",\
    },"

sed -i "/networks: {/a $main_content" truffle-config.js

VERSION=$(grep -oP '(?<=pragma solidity \^)[0-9.]*' “$FILENAME”)
sed -i "s/\(version: \"\)[^\"]*\(\"\)/\1$VERSION\2/" truffle-config.js
