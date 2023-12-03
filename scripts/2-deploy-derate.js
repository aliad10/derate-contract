const hre = require('hardhat');

async function main() {
  let accessRestrictionAddress = process.env.ACCESS_RESTRICTION_ADDRESS;
  console.log('1111', accessRestrictionAddress);
  const derate = await hre.ethers.deployContract('Rate', [
    accessRestrictionAddress,
  ]);

  await derate.waitForDeployment();

  console.log('derate', derate.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
