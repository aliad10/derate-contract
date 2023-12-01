// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import IAccessRestriction from "./../accessRestriction/IAccessRestriction.sol";
import "./IRate.sol";
import "./../accessRestriction/IAccessRestriction.sol";

contract Rate is IRate {
    IAccessRestriction public accessRestriction;
    struct Service {
        address submiter;
        string info;
        bool exists;
    }

    struct Feedback {
        string info;
        bool exists;
    }
    bytes32 public constant ADD_SERVICE_TYPE_HASH =
        keccak256(
            "addService(uint256 nonce,string infoHash,string serviceAddress)"
        );

    bytes32 public constant FEEDBACK_TYPE_HASH =
        keccak256(
            "feedbackToService(uint256 nonce,string infoHash,string serviceAddress)"
        );
    bytes32 public constant FEEDBACK_ON_FEEDBACK_TYPE_HASH =
        keccak256(
            "feedbackToFeedback(uint256 nonce,string infoHash,string prevSubmiter,string serviceAddress)"
        );

    mapping(address => Service) public services;
    mapping(address => mapping(address => Feedback)) public serviceFeedbacks; //submiter->service->data
    mapping(address => mapping(address => mapping(address => Feedback)))
        public feedbackFeedbacks; // submiter->prevSubmiter->service->data

    mapping(address => uint256) public serviceNonce;
    mapping(address => uint256) public feedbackNonce;
    mapping(address => uint256) public feedbackOnfeedbackNonce;

    constructor(address _address) {
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
        address _submiter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override isScriptOnly(msg.sender) {
        require(serviceNonce[_submiter] < _nonce, "nonce is incorrect");

        _checkSigner(
            _buildDomainSeparator(),
            keccak256(
                abi.encode(
                    ADD_SERVICE_TYPE_HASH,
                    _nonce,
                    keccak256(bytes(_infoHash)),
                    _service
                )
            ),
            _submiter,
            _v,
            _r,
            _s
        );

        Service storage serviceData = services[_service];
        require(serviceData.exists == false, "service already submited");
        serviceData.info = _infoHash;
        serviceData.submiter = _submiter;
        serviceData.exists = true;

        serviceNonce[_submiter] = _nonce;

        emit ServiceAdded(_service, _submiter, _infoHash);
    }

    function submitFeedbackToService(
        uint256 _nonce,
        address _submiter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override isScriptOnly(msg.sender) {
        require(feedbackNonce[_submiter] < _nonce, "nonce is incorrect");
        _checkSigner(
            _buildDomainSeparator(),
            keccak256(
                abi.encode(
                    FEEDBACK_TYPE_HASH,
                    _nonce,
                    keccak256(bytes(_infoHash)),
                    _service
                )
            ),
            _submiter,
            _v,
            _r,
            _s
        );

        Feedback storage feedbackData = serviceFeedbacks[_submiter][_service];

        require(feedbackData.exists == false, "feedback already submited");
        feedbackData.info = _infoHash;
        feedbackData.exists = true;

        feedbackNonce[_submiter] = _nonce;

        emit FeedbackSubmited(_service, _submiter, _infoHash);
    }

    function submitFeedbackToFeedback(
        uint256 _nonce,
        address _prevSubmiter,
        address _submiter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override isScriptOnly(msg.sender) {
        require(
            feedbackOnfeedbackNonce[_submiter] < _nonce,
            "nonce is incorrect"
        );

        _checkSigner(
            _buildDomainSeparator(),
            keccak256(
                abi.encode(
                    FEEDBACK_ON_FEEDBACK_TYPE_HASH,
                    _nonce,
                    keccak256(bytes(_infoHash)),
                    _prevSubmiter,
                    _service
                )
            ),
            _submiter,
            _v,
            _r,
            _s
        );

        Feedback storage feedbackData = feedbackFeedbacks[_submiter][
            _prevSubmiter
        ][_service];

        require(feedbackData.exists == false, "feedback already submited");
        feedbackData.info = _infoHash;
        feedbackData.exists = true;

        feedbackOnfeedbackNonce[_submiter] = _nonce;
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
