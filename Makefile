-include .env
build:; forge build
test:; forge test
deploy_anvil:; forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(RPC_ANVIL_URL) --account devWallet --broadcast
deploy_sepolia:; forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(RPC_SEPOLIA_URL) --account sepoliaWallet --broadcast --verify --etherscan-api-key $(ETHER_SCAN_API)

	