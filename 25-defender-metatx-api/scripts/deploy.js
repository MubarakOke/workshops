require('dotenv').config();

const { Defender } = require('@openzeppelin/defender-sdk');
const { ethers } = require('hardhat')
const { writeFileSync } = require('fs')

async function main() {
  const creds = {
    relayerApiKey: process.env.RELAYER_API_KEY,
    relayerApiSecret: process.env.RELAYER_API_SECRET,
  };
  const client = new Defender(creds);

  const provider = client.relaySigner.getProvider();
  const signer = client.relaySigner.getSigner(provider, { speed: 'fast' });

  const forwarderFactory = await ethers.getContractFactory('ERC2771Forwarder', signer)
  const forwarder = await forwarderFactory.deploy('ERC2771Forwarder')
    .then((f) => f.deployed())

  const ENSFactory = await ethers.getContractFactory('ENS', signer)
  const ENS = await ENSFactory.deploy(forwarder.address)
    .then((f) => f.deployed())

  const CHATFactory = await ethers.getContractFactory('Chat', signer)
  const CHAT = await CHATFactory.deploy(ENS.address, forwarder.address)
    .then((f) => f.deployed())

  writeFileSync(
    'deploy.json',
    JSON.stringify(
      {
        ERC2771Forwarder: forwarder.address,
        ENS: ENS.address,
        CHAT: CHAT.address,
      },
      null,
      3
    )
  )

  console.log(
    `ERC2771Forwarder: ${forwarder.address}\nENS: ${ENS.address}\nCHAT: ${CHAT.address}`
  )
}

if (require.main === module) {
  main().catch(console.error);
}