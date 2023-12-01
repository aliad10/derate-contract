// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRate {
    event ServiceAdded(address service, address submiter, string info);
    event FeedbackSubmited(address service, address submiter, string info);

    function addService(
        uint256 _nonce,
        address _submiter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function submitFeedbackToService(
        uint256 _nonce,
        address _submiter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function submitFeedbackToFeedback(
        uint256 _nonce,
        address _prevSubmiter,
        address _submiter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;
}
