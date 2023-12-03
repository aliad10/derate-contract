require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();

module.exports = {
  networks: {
    localhost: { url: 'http://127.0.0.1:8545' },

    hardhat: {},
  },
  solidity: {
    version: '0.8.20',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },

  mocha: { timeout: 40000000 },
};
