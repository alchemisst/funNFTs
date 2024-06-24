const networkConfig = {
    31337: {
        name: "localhost",
        entraceFee: ethers.utils.parseEther("0.01"),
        gasLane:"0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae",
        callbackGasLimit: "500000",
        interval:"30",
        mintFee:"100000000000000000"
      
    },
    11155111:{
        name:"sepolia",
        vrfCoordinatorV2:"0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B",
        entraceFee: ethers.utils.parseEther("0.01"),
        gasLane:"0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae",
        subscriptionId:"85028811853273159087720906159607873412698283647064817104863291165807026838988",
        callbackGasLimit: "2500000",
        interval:"30",
        mintFee:"1000000000000000",
    },


   
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
}