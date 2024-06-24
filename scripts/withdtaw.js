const {getNamedAccounts, ethers} = require("hardhat");

const address = 0; //contract address
const abi = 0; //getabi

/// This uses the function selector method

const main = async () => {
    const {deployer} = await getNamedAccounts();
    const signer = await ethers.getSigner(deployer);

    // Function selector for withdraw()
    const withdrawSelector = ethers.utils.id("withdraw()").slice(0, 10);

    // Create the transaction object
    const tx = {
        to: address,
        data: withdrawSelector,
        gasLimit: ethers.utils.hexlify(100000),  // Adjust the gas limit as necessary
        gasPrice: await signer.getGasPrice()    // Fetch current gas price
    };

    console.log("Sending transaction...");

    // Send the transaction
    const transactionResponse = await signer.sendTransaction(tx);
    console.log("Transaction Hash:", transactionResponse.hash);

    // Wait for the transaction to be confirmed
    const receipt = await transactionResponse.wait();
    console.log("Transaction was mined in block:", receipt.blockNumber);
   


};

main().then(()=> process.exit(0))
.catch((error)=>{
    console.error(error)
    process.exit(1);
})