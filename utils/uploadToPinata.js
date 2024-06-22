require("dotenv").config()
const pinataSDK = require('@pinata/sdk');
const path = require('path');
const pinata = new pinataSDK(process.env.PUBLIC_PINATA_KEY,process.env.PUBLIC_PINATA_SECRET_KEY);
const fs = require("fs")

async function uploadToPinata(imagesFilePath){
  const fullImagesPath = path.resolve(imagesFilePath);
  const files = fs.readdirSync(fullImagesPath)
  

  const responses = []
  for(fileIndex in files){
    const readableStream = fs.createReadStream(`${fullImagesPath}/${files[fileIndex]}`)
  
    try{
      const response = await pinata.pinFileToIPFS(readableStream); 
      responses.push(response)
      
    }catch(e){
      console.log(e);
    }
  }
  return { responses, files }

}

async function storeTokenUriMetadata(metadata){
  const options = {
    pinataMetadata: {
        name: metadata.name,
    },
}
try {
    const response = await pinata.pinJSONToIPFS(metadata, options)
    return response
} catch (error) {
    console.log(error)
}
return null
}

module.exports = {uploadToPinata,storeTokenUriMetadata}
