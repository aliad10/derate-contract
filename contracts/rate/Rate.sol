// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IRate.sol";
import "./../accessRestriction/IAccessRestriction.sol";

contract Rate is IRate {
    address public accessRestriction;
    struct Service {
        address submitter;
        string info;
        bool exists;
    }

    struct Feedback {
        string info;
        uint score;
        bool exists;
    }
    bytes32 public constant ADD_SERVICE_TYPE_HASH =
        keccak256(
            "addService(uint256 nonce,string infoHash,address serviceAddress)"
        );

    bytes32 public constant FEEDBACK_TYPE_HASH =
        keccak256(
            "feedbackToService(uint256 nonce,uint256 score,string infoHash,address serviceAddress)"
        );
    bytes32 public constant FEEDBACK_ON_FEEDBACK_TYPE_HASH =
        keccak256(
            "feedbackToFeedback(uint256 nonce,uint256 score,string infoHash,address prevSubmitter,address serviceAddress)"
        );

    mapping(address => Service) public services;
    mapping(address => mapping(address => Feedback)) public serviceFeedbacks; //submitter->service->data
    mapping(address => mapping(address => mapping(address => Feedback)))
        public feedbackFeedbacks; // submitter->prevSubmitter->service->data

    mapping(address => uint256) public serviceNonce;
    mapping(address => uint256) public feedbackNonce;
    mapping(address => uint256) public feedbackOnfeedbackNonce;

    constructor(address _address) {
        accessRestriction = _address;
    }

    modifier validAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }
    modifier isScriptOnly(address _address) {
        require(
            IAccessRestriction(accessRestriction).isScript(_address),
            "caller is not script!"
        );
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
    ) external override isScriptOnly(msg.sender) {
        require(serviceNonce[_submitter] < _nonce, "nonce is incorrect");

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
            _submitter,
            _v,
            _r,
            _s
        );

        Service storage serviceData = services[_service];
        require(serviceData.exists == false, "service already submited");
        serviceData.info = _infoHash;
        serviceData.submitter = _submitter;
        serviceData.exists = true;

        serviceNonce[_submitter] = _nonce;

        emit ServiceAdded(_service, _submitter, _infoHash);
    }

    function submitFeedbackToService(
        uint256 _nonce,
        uint _score,
        address _submitter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override isScriptOnly(msg.sender) {
        require(feedbackNonce[_submitter] < _nonce, "nonce is incorrect");
        require(_score < 101 && _score >= 0, "score out of range");
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
            _submitter,
            _v,
            _r,
            _s
        );

        Feedback storage feedbackData = serviceFeedbacks[_submitter][_service];

        require(feedbackData.exists == false, "feedback already submited");
        feedbackData.info = _infoHash;
        feedbackData.score = _score;
        feedbackData.exists = true;

        feedbackNonce[_submitter] = _nonce;

        emit FeedbackSubmited(_service, _submitter, _infoHash, _score);
    }

    function submitFeedbackToFeedback(
        uint256 _nonce,
        uint _score,
        address _prevSubmitter,
        address _submitter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override isScriptOnly(msg.sender) {
        require(
            feedbackOnfeedbackNonce[_submitter] < _nonce,
            "nonce is incorrect"
        );
        require(_score < 101 && _score >= 0, "score out of range");

        _checkSigner(
            _buildDomainSeparator(),
            keccak256(
                abi.encode(
                    FEEDBACK_ON_FEEDBACK_TYPE_HASH,
                    _nonce,
                    keccak256(bytes(_infoHash)),
                    _prevSubmitter,
                    _service
                )
            ),
            _submitter,
            _v,
            _r,
            _s
        );

        Feedback storage feedbackData = feedbackFeedbacks[_submitter][
            _prevSubmitter
        ][_service];

        require(feedbackData.exists == false, "feedback already submited");
        feedbackData.info = _infoHash;
        feedbackData.score = _score;
        feedbackData.exists = true;
        emit FeedbackOnFeedbackSubmited(
            _service,
            _prevSubmitter,
            _submitter,
            _infoHash,
            _score
        );
        feedbackOnfeedbackNonce[_submitter] = _nonce;
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
