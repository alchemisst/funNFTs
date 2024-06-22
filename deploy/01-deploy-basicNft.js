const { network, deployments, getNamedAccounts, ethers } = require("hardhat");
const { developmentChains, networkConfig } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");



module.exports = async ({getNamedAccounts,deployments})=>{
    const {deploy,log} = deployments

    const { deployer } = await getNamedAccounts()

    const BasicNft = await deploy("BasicNft",{

        from:deployer,
        args: [],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1

    })

    log(`NFT deployed at ${BasicNft.address}`)

    if(
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
      ) {
        await verify(BasicNft.address,[]);
        log("---VERIFIED---")
      }




}

module.exports.tags = ["all","basicNft"]