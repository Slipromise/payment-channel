pragma solidity >=0.4.22;

contract PaymentChannel {
    // 付款方
    address payable public sender;
    // 收款方
    address payable public recipient;
    // 有效期限
    uint256 public expiration;

    constructor (address payable _recipient, uint256 duration) payable {
        sender = payable(msg.sender);
        recipient = _recipient;
        expiration =  block.timestamp + duration;
    }

    // 是否為付款簽名 
    function isValidSignature (uint256 amount, bytes memory signature) 
        internal 
        view 
        returns (bool) 
    {
        bytes32 message = prefixed(keccak256(abi.encodePacked(this,amount)));
        
        return recoverSigner(message, signature) == sender;
    }

    // 算總賬（收款方發起需帶有付款簽名）
    function close(uint256 amount, bytes memory signature) public {
        require(msg.sender == recipient);
        require(isValidSignature(amount, signature));
        recipient.transfer(amount);
        selfdestruct(sender);
    }

    // 延期
    function extend(uint256 newExpiration) public {
        require(msg.sender == sender);
        require(newExpiration > expiration);
        expiration = newExpiration;
    }

    // 遇時撤回付款方資金
    function claimTimeout() public {
        require(block.timestamp > expiration);
        selfdestruct(sender);
    }

    // 簽名資訊解析 v r s
    function splitSignature(bytes memory sig) 
        internal 
        pure 
        returns(uint8 v, bytes32 r, bytes32 s ) 
    {
        require(sig.length == 65);

        assembly {
            r := mload(add(sig,32))
            s := mload(add(sig,64))
            v := byte(0,mload(add(sig,96)))
        }

        return (v,r,s);
    }

    // 從簽名資料獲得簽名者地址
    function recoverSigner(bytes32 mesage, bytes memory sig) 
        internal 
        pure 
        returns (address) 
    {
        (uint8 v,bytes32 r,bytes32 s) = splitSignature(sig);
        return ecrecover(mesage, v, r, s);
    }

    // 加入慣例前名字首
    function prefixed(bytes32 hash) 
        internal 
        pure 
        returns(bytes32)
    {
        return keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32',hash));
    }
}