// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRate {
    event ServiceAdded(address service, address submitter, string info);
    event FeedbackSubmited(address service, address submitter, string info);
    event FeedbackOnFeedbackSubmited(
        address service,
        address prevSubmitter,
        address submitter,
        string info
    );

    function addService(
        uint256 _nonce,
        address _submitter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function submitFeedbackToService(
        uint256 _nonce,
        address _submitter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function submitFeedbackToFeedback(
        uint256 _nonce,
        address _prevSubmitter,
        address _submitter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;
}
