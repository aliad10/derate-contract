const hre = require('hardhat');

async function main() {
  const derate = await hre.ethers.deployContract('TestRate');

  await derate.waitForDeployment();

  console.log('test derate contract addrress: ', derate.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
