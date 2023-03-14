const { ethers } = require("hardhat");

const tokenAddress = ""; // deployed crowd fund token address

async function main() {
  const CrowdFundFactory = await ethers.getContractFactory("CrowdFunding");
  console.log("Deploying crowd funding contract.....");
  const crowdFundContract = await CrowdFundFactory.deploy(
    tokenAddress,
    timeInterval
  );
  await crowdFundContract.deployed();
  console.log("Crowd Funding contract address: ", crowdFundContract.address);
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
