-include .env

build:; forge build
anvil_deploy:; forge script script/Counter.s.sol:CounterScript --rpc-url http://127.0.0.1:8545 --private-key -- --broadcast -vvvv
sepolia_deploy:; forge script script/Counter.s.sol:CounterScript --rpc-url $(SEPOLIA_RPC_URL) --account deployer --broadcast -vvvv
test:; forge test --match-contract CounterTest 
snap:; forge snapshot
