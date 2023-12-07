// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IRate.sol";

contract TestRate is IRate {
    function addService(
        uint256 _nonce,
        address _submitter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
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
    ) external override {
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
    ) external override {
        emit FeedbackOnFeedbackSubmited(
            _service,
            _prevSubmitter,
            _submitter,
            _infoHash,
            _score
        );
    }
}
