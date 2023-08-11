#!/bin/sh

FILENAME="$1"
TIMEOUT="$2"
BIN="$3"
MAIN="$4"

export PATH="$BIN:$PATH"
chmod +x "$BIN/solc"

CONTRACT="${FILENAME%.sol}"
CONTRACT="${CONTRACT##*/}"
CONTRACTS=$(python3 "$BIN"/printContractNames.py "$FILENAME")

# OPT_CONTRACT=""
# if [ "$MAIN" -eq 1 ]; then
#     if (echo "$CONTRACTS" | grep -q "$CONTRACT"); then
#         OPT_CONTRACT="--contract $CONTRACT"
#     else
#         echo "Contract '$CONTRACT' not found in $FILENAME"
#         exit 127
#     fi
# fi

# OPT_TIMEOUT=""
# if [ "$TIMEOUT" -gt 0 ]; then
#     # TO = TIMEOUT * 80%
#     # the remaining 20% are for honeybadger to finish
#     TO=$(( (TIMEOUT*8+9)/10 ))
#     OPT_TIMEOUT="-glt $TO"
# fi


for CONTRACT in $CONTRACTS; do
    mkdir -p "$CONTRACT"
    cd "$CONTRACT"
    # pwd
    truffle init
    cp "$FILENAME" ./contracts/

    echo "$FILENAME"

    cd ..
    # pwd
    # ls
    ls "$CONTRACT"/migrations/
    # ./scripts/truffle.sh
    file_name="2_deploy_contracts.js"
    file_content="var contract = artifacts.require(\"$FILENAME\");\nmodule.exports = function(deployer) {\n  deployer.deploy(contract);\n};"
    
    cd "$CONTRACT"
    echo -e "$file_content" > "migrations/$file_name"
    ls
    ls contracts/
    pwd
    ls
    
    cd contracts
    ls
    
    VERSION=$(grep -oP '(?<=pragma solidity )\d+\.\d+\.\d+' "$CONTRACT.sol" | cut -d'"' -f3)


    cd ..
    conf="module.exports = {
        networks: {
            development: {
                host: \"127.0.0.1\",
                port: 8545,
                network_id: \"*\",
            }
        },
        compilers: {
            solc: {
                version: \"$VERSION\",
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        }
    };"
    echo "$conf" > truffle-config.js


    cat truffle-config.js
    cd ..
    pwd

    python3 script/extract.py --proj "$CONTRACT" --port 8545
    
    python3 -m ilf --proj "./$CONTRACT" --contract "$CONTRACT" --fuzzer symbolic --model ./model/ --limit 2000
    
    cd ..
done