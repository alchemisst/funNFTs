const { assert, expect } = require("chai")
const { network, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")

//writing the test code from here..

!developmentChains.includes(network.name)
    ? describe.skip
    : describe('Random IPFS Contract Tests', () => { 

    const {deploy,log} = deployments
    let randomIpfs,deployer;
    beforeEach(async ()=>{
        let accounts = await ethers.getSigners();
        deployer = accounts[0];
        await deployments.fixture("main");
        randomIpfs = await ethers.getContract("RandomNftIpfs")
    })

    describe('Contructor', () => { 
        it("initialize the constructor random",async ()=>{
            let skurllyUri = await randomIpfs.getSkullyTokenUris(0)
            assert(skurllyUri.includes("ipfs://"))
        }) 
     })
     describe("requestNft", () => {
        it("fails if payment isn't sent with the request", async function () {
            await expect(randomIpfs.requestNft()).to.be.revertedWith(
                "RandomNftIpfs_NeedMoreEthToMint"
            )
        })
        it("reverts if payment amount is less than the mint fee", async function () {
            const fee = await randomIpfs.getMintFee()
            await expect(
                randomIpfs.requestNft({
                    value: fee.sub(ethers.utils.parseEther("0.001")),
                })
            ).to.be.revertedWith("RandomNftIpfs_NeedMoreEthToMint")
        })
        it("emits an event and kicks off a random word request", async function () {
            const fee = await randomIpfs.getMintFee()
            await expect(randomIpfs.requestNft({ value: fee.toString() })).to.emit(
                randomIpfs,
                "NftRequested"
            )
            
        })
    })

    
})

module.exports.tags = ["single"];