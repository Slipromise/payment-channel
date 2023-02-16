const PaymentChannel = artifacts.require("PaymentChannel");

module.exports = function (deployer,accounts) {
  deployer.deploy(PaymentChannel, '0x9726440cAa8De38863Cb2E1de66a0EA2Ed9ba16C',120,{value:'5000000000000000000' });
};