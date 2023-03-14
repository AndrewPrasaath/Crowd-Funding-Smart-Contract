const { ethers } = require("hardhat");

async function main() {
  const TokenFactory = await ethers.getContractFactory("ERC20");
  console.log("Deploying crowd funding token.....");
  const crowdFundToken = await TokenFactory.deploy();
  await crowdFundToken.deployed();
  console.log("Token address: ", crowdFundToken.address);
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
