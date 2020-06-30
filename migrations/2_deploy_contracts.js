var contract = artifacts.require("Distribute");

module.exports = function(deployer) {
  let ANYtoken = "0xC20b5E92E1ce63Af6FE537491f75C19016ea5fb4"
  deployer.deploy(contract, ANYtoken);
};
