// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import IAccessRestriction from "./../accessRestriction/IAccessRestriction.sol";
import "./IRate.sol";
import "./IAccessRestriction.sol";

contract Rate is IRate {
    IAccessRestriction public accessRestriction;
    struct Service {
        address submiter;
        string info;
        bool exists;
    }
    bytes32 public constant ADD_SERVICE_TYPE_HASH =
        keccak256(
            "addService(uint256 nonce,string infoHash,string serviceAddress)"
        );
    mapping(address => Service) public services;

    constructor(address _accessRestrictionAddress) {
        IAccessRestriction accessRestriction = IAccessRestriction(_address);
    }

    modifier validAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }
    modifier isScriptOnly(address _address) {
        require(accessRestriction.isScript(_address), "caller is not script!");
        _;
    }

    function addService(
        uint256 _nonce,
        address _submitter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external isScriptOnly(msg.sender) {
        _checkSigner(
            _buildDomainSeparator(),
            keccak256(
                abi.encode(
                    ADD_SERVICE_TYPE_HASH,
                    _nonce,
                    keccak256(bytes(_infoHash)),
                    _service,

                )
            ),
            _submitter,
            _v,
            _r,
            _s
        );

        Service storage serviceData = services[_service];
        require(
            serviceData.submiter == address(0),
            "service already submitted"
        );
        serviceData.info = _infoHash;
        serviceData.submiter = _submiter;
        serviceData.exists = true;

        emit ServiceAdded(_service, _submiter, _infoHash);
    }

    function _toTypedDataHash(
        bytes32 _domainSeperator,
        bytes32 _structHash
    ) private pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19\x01", _domainSeperator, _structHash)
            );
    }

    /**
     * @dev check if the given planter is the signer of given signature or not
     */
    function _checkSigner(
        bytes32 _domainSeparator,
        bytes32 _hashStruct,
        address _signer,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure {
        bytes32 hash = _toTypedDataHash(_domainSeparator, _hashStruct);

        address signer = ecrecover(hash, _v, _r, _s);

        require(signer == _signer, "invalid signature");
    }

    /**
     * @dev return domain separator
     */
    function _buildDomainSeparator() private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("Derate Protocol")),
                    keccak256(bytes("1")),
                    block.chainid,
                    address(this)
                )
            );
    }
}
