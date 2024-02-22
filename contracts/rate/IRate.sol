// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRate {
    event ServiceAdded(address service, address submitter, string info);
    event FeedbackSubmited(
        address service,
        address submitter,
        string info,
        uint score
    );
    event FeedbackOnFeedbackSubmited(
        address service,
        address prevSubmitter,
        address submitter,
        string info,
        uint score
    );
    struct ServiceData {
        uint256 nonce;
        address service;
        string infoHash;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct ExecuteServiceData {
        address submitter;
        ServiceData[] data;
    }
    struct FeedbackToServiceData {
        uint256 nonce;
        uint256 score;
        address service;
        string infoHash;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct ExecuteFeedbackToServiceData {
        address submitter;
        FeedbackToServiceData[] data;
    }
    struct FeedbackToFeedbackData {
        uint256 nonce;
        uint256 score;
        address prevSubmitter;
        address service;
        string infoHash;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct ExecuteFeedbackToFeedbackData {
        address submitter;
        FeedbackToFeedbackData[] data;
    }

    function addService(
        uint256 _nonce,
        address _submitter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function addServiceBatch(
        ExecuteServiceData[] calldata _executeServiceData
    ) external;

    function submitFeedbackToService(
        uint256 _nonce,
        uint _score,
        address _submitter,
        address _service,
        string memory _infoHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function submitFeedbackToServiceBatch(
        ExecuteFeedbackToServiceData[] calldata _executeFeedbackToServiceData
    ) external;

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
    ) external;

    function submitFeedbackToFeedbackBatch(
        ExecuteFeedbackToFeedbackData[] calldata _executeFeedbackToFeedbackData
    ) external;
}
