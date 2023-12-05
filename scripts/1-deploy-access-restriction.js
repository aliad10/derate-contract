const hre = require('hardhat');

const { ethers } = require('hardhat');
async function main() {
  const [deployer] = await ethers.getSigners();

  const accessRestriction = await hre.ethers.deployContract(
    'AccessRestriction',
    [deployer.address]
  );

  await accessRestriction.waitForDeployment();

  console.log('accessRestriction contract address', accessRestriction.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
