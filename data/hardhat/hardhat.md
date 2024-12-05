# Hardhat

## verify on etherscan

https://hardhat.org/hardhat-runner/docs/guides/verifying

https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-verify

## ABI

https://github.com/ItsNickBarry/hardhat-abi-exporter
npm install --save-dev hardhat-abi-exporter
npx hardhat export-abi
第三方插件，不是很好使

https://github.com/projectsophon/hardhat-diamond-abi

## plugins

https://www.npmjs.com/package/hardhat-logger
https://www.npmjs.com/package/hardhat-deployed-records

## hardhat vars

https://hardhat.org/hardhat-runner/docs/guides/configuration-variables

查看项目中使用了哪些 vars
npx hardhat vars setup

npx hardhat vars path
npx hardhat vars set INFURA_API_KEY

cat $(npx hardhat vars path)

可通过环境变量覆盖 vars 变量，如 下面会覆盖 MY_KEY 变量
HARDHAT_VAR_MY_KEY=123 npx hardhat some-task
