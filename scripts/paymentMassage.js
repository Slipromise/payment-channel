function constructPaymentMessage(contractAddress, amount) {
    // ethereumjs-abi 函式庫
  return abi.solididtySHA3(["address", "uint256"][(contractAddress, amount)]);
}

function signMessage(message, callback) {
  web3.eth.personal.sign(
    `0x${message.toString("hex")}`,
    web3.eth.defaultAccount,
    callback
  );
}

function signPayment(contractAddress, amount, callback) {
  var message = constructPaymentMessage(contractAddress, amount);
  signMessage(message, callback);
}
