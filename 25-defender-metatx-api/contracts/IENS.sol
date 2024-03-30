// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IENS {
    struct Profile {
        string userName;
        address userAddress;
        string imageUri;
    }

    function getDetailsAddressFromName(
        string calldata _name
    ) external  view returns (Profile memory);

    function getAddressFromName(
        string calldata _name
    ) external view returns (address);

    function getNameFromAddress(
        address _address
    ) external view returns (string memory);
}
