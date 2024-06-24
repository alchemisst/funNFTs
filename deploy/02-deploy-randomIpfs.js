require("dotenv").config();
const { network, deployments, getNamedAccounts, ethers } = require("hardhat");
const {
  developmentChains,
  networkConfig,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

const {
  uploadToPinata,
  storeTokenUriMetadata,
} = require("../utils/uploadToPinata");
const location = "./assets/images/";

const FUND_AMOUNT = ethers.utils.parseEther("5");

const metadataTemplate = {
  name: "",
  desc: "",
  image: "",
};
let tokenUris = [
  "ipfs://QmTsmrcuwnLC1ihEi3nB4KySiaE4GuhNWFgdM51dLsqqCj",
  "ipfs://QmV4kbNCeoDJ5EgfjwE8HcrLTjEFgGye4JwSp3GRnLv237",
  "ipfs://QmRREeKyJw6jc1m4JPJ6ERk9FDn7pik3faxgj47WgeNJfW",
];

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;

  const { deployer } = await getNamedAccounts();

  if (process.env.UPLOAD_TO_PINATA == "true") {
    tokenUris = await handleTokenUris();
  }

  let vrfCoordinatorV2Address, vrfCoordinatorV2Mock, subscriptionId;
  const chainId = network.config.chainId;

  if(developmentChains.includes(chainId)){
    console.log("enter--0320984-----------------------------------")
    vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock");

    
    vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
    const transactionResponse = await vrfCoordinatorV2Mock.createSubscription();
    const transactionReceipt = await transactionResponse.wait();
    subscriptionId = transactionReceipt.events[0].args.subId.toNumber();

    await vrfCoordinatorV2Mock.fundSubscription(
      subscriptionId,
      FUND_AMOUNT
    );
  } else {
    console.log("not run -------------------------------------------")
    vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2;
    subscriptionId = networkConfig[chainId].subscriptionId;
    console.log("this runnnn--------------")
  }

  const arguments = [
    vrfCoordinatorV2Address,
    subscriptionId,
    networkConfig[chainId]["gasLane"],
    networkConfig[chainId]["callbackGasLimit"],
    tokenUris,
    networkConfig[chainId]["mintFee"],
  ];

  const randomIpfsNft = await deploy("RandomNftIpfs", {
    from: deployer,
    args: arguments,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  if (chainId == 31337) {
    await vrfCoordinatorV2Mock.addConsumer(
      subscriptionId,
      randomIpfsNft.address
    );
  }

  // Verify the deployment
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    log("Verifying...");
    await verify(randomIpfsNft.address, arguments);
  }
};
async function handleTokenUris() {
  const tokenUris = [];
  const { responses: imageUploadResponses, files } = await uploadToPinata(
    location
  );
  for (const imageUploadResponseIndex in imageUploadResponses) {
    let tokenUriMetadata = { ...metadataTemplate };
    tokenUriMetadata.name = files[imageUploadResponseIndex].replace(
      /\b.png|\b.jpg|\b.jpeg/,
      ""
    );
    tokenUriMetadata.desc = `A Badass ${tokenUriMetadata.name} Skully!`;
    tokenUriMetadata.image = `ipfs://${imageUploadResponses[imageUploadResponseIndex].IpfsHash}`;
    console.log(`Uploading ${tokenUriMetadata.name}...`);
    const metadataUploadResponse = await storeTokenUriMetadata(
      tokenUriMetadata
    );
    tokenUris.push(`ipfs://${metadataUploadResponse.IpfsHash}`);
  }
  console.log("Token URIs uploaded! They are:");
  console.log(tokenUris);
  return tokenUris;
}

module.exports.tags = ["all", "randomIpfs", "main"];
