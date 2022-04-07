async function main() {

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // deploy contracts here:
  const Token = await ethers.getContractFactory("SampleToken");
  const token = await Token.deploy(1000000000);
  
  const Vault = await ethers.getContractFactory("Vault");
  const vault = await Vault.deploy("Wrapped SampleToken", "wSAM", token.address);

  const Staking = await ethers.getContractFactory("StakingRewards");
  const staking = await Staking.deploy(token.address);

  console.log("Token address:", token.address);
  console.log("Vault address:", vault.address);
  console.log("StakingRewards address:", staking.address);

  // For each contract, pass the deployed contract and name to this function to save a copy of the contract ABI and address to the front end.
  saveFrontendFiles(token, "SampleToken");
  saveFrontendFiles(vault, "Vault");
  saveFrontendFiles(staking, "StakingRewards");
}

function saveFrontendFiles(contract, name) {
  const fs = require("fs");
  const contractsDir = __dirname + "/../../frontend/contractsData";

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    contractsDir + `/${name}-address.json`,
    JSON.stringify({ address: contract.address }, undefined, 2)
  );

  const contractArtifact = artifacts.readArtifactSync(name);

  fs.writeFileSync(
    contractsDir + `/${name}.json`,
    JSON.stringify(contractArtifact, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
