const { getNamedAccounts, ethers } = require("hardhat");

const address = 0; //contract address
const abi = 0; //getabi

const main = async () => {
  const AMOUNT = 1000000000000000;

  const { deployer } = await getNamedAccounts();
  const randomIpfs = await ethers.getContractAt(abi, address, deployer);
  console.log("Fetched Contract......");
  console.log(await randomIpfs.withdraw());
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
